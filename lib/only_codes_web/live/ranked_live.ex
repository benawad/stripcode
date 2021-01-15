defmodule OnlyCodesWeb.RankedLive do
  use OnlyCodesWeb, :live_view
  alias OnlyCodes.{Repo, Choice, User}
  import Ecto.Query
  alias Ecto.Multi

  def reset_assigns(socket) do
    %{
      socket
      | assigns: %{flash: %{}, live_action: :index, timer: socket.assigns[:timer]}
    }
  end

  def fetch_initial_data(socket, userId) do
    u =
      Repo.one(
        from(
          u in subquery(
            from all_users in User,
              select: %{
                id: all_users.id,
                currentRank: over(row_number(), order_by: [desc: all_users.points]),
                currentLang: all_users.currentLang,
                totalPoints: all_users.points,
                currentProblems: all_users.currentProblems
              }
          ),
          where: u.id == ^userId,
          limit: 1
        )
      )

    query =
      from gg in OnlyCodes.Question,
        join: a0 in assoc(gg, :answer0GitHubRepo),
        join: a1 in assoc(gg, :answer1GitHubRepo),
        join: a2 in assoc(gg, :answer2GitHubRepo),
        join: a3 in assoc(gg, :answer3GitHubRepo),
        join: a4 in assoc(gg, :answer4GitHubRepo),
        left_join: c in Choice,
        on: c.questionId == gg.id and c.userId == ^userId,
        where: is_nil(c.questionId),
        limit: 1,
        order_by: fragment("RANDOM()"),
        preload: [
          answer0GitHubRepo: a0,
          answer1GitHubRepo: a1,
          answer2GitHubRepo: a2,
          answer3GitHubRepo: a3,
          answer4GitHubRepo: a4
        ]

    query_with_current_lang =
      if u.currentLang == "all languages",
        do: query,
        else: where(query, [gg], gg.lang == ^u.currentLang)

    q_id =
      if Map.has_key?(u.currentProblems, u.currentLang),
        do: u.currentProblems[u.currentLang],
        else: -1

    tmp_q =
      Repo.one(
        if q_id != -1,
          do: where(query_with_current_lang, [gg], gg.id == ^q_id),
          else: query_with_current_lang
      )

    # if for some reason the question can't be found
    q = if q_id != -1 and !tmp_q, do: Repo.one(query_with_current_lang), else: tmp_q

    if q do
      answer_list =
        Enum.map(0..4, fn x ->
          Map.get(q, String.to_existing_atom("answer" <> Integer.to_string(x) <> "GitHubRepo"))
        end)

      if socket.assigns[:timer] do
        Process.send_after(self(), {:tick, q.id}, 5000)
      end

      show_entire_code = q_id == q.id
      starting_points = if u.currentLang == "all languages", do: 120, else: 100
      points = if show_entire_code, do: 10, else: starting_points
      numRemainingBlocks = if show_entire_code, do: 0, else: Enum.count(q.codeBlocks) - 1

      code =
        if show_entire_code, do: Enum.join(q.codeBlocks, "\n"), else: Enum.at(q.codeBlocks, 0)

      assign(reset_assigns(socket),
        page: "good",
        totalPoints: u.totalPoints,
        numActiveUsers: LiveMonitor.get_count(),
        started: false,
        currentRank: u.currentRank,
        currentLang: u.currentLang,
        filename: Enum.at(String.split(q.path, "/"), -1),
        questionId: q.id,
        userId: userId,
        points: points,
        codeBlockIndex: 0,
        codeLang: q.lang,
        codeBlocks: q.codeBlocks,
        numRemainingBlocks: numRemainingBlocks,
        code: code,
        guessGitHubRepoId: "",
        publicCorrectGitHubRepoId: "",
        correctGitHubRepoId: q.correctGitHubRepoId,
        answer_list: answer_list,
        answers:
          answer_list
          |> Enum.map(fn x ->
            %{
              ownerAndName: x.ownerAndName,
              githubRepoId: x.githubRepoId,
              description: x.description
            }
          end)
      )
    else
      assign(
        reset_assigns(socket),
        page: "good",
        totalPoints: u.totalPoints,
        numActiveUsers: LiveMonitor.get_count(),
        currentRank: u.currentRank,
        currentLang: u.currentLang,
        userId: userId
      )
    end
  end

  @impl true
  def handle_params(_, uri, socket) do
    if not (uri =~ "no-timer") do
      if socket.assigns[:questionId] do
        Process.send_after(self(), {:tick, socket.assigns.questionId}, 5000)
      end

      {:noreply, assign(socket, timer: true)}
    else
      {:noreply, assign(socket, timer: false)}
    end
  end

  def show_another_block(socket) do
    codeBlockIndex = socket.assigns.codeBlockIndex + 1

    if socket.assigns.numRemainingBlocks <= 0 or socket.assigns.publicCorrectGitHubRepoId != "" do
      {:noreply, socket}
    else
      newPoints =
        if socket.assigns.publicCorrectGitHubRepoId != "",
          do: socket.assigns.points,
          else:
            socket.assigns.points - ceil(90 / max(1, Enum.count(socket.assigns.codeBlocks) - 1))

      if not socket.assigns.started do
        codeLang =
          if socket.assigns.currentLang == "all languages",
            do: "all languages",
            else: socket.assigns.codeLang

        from(u in User,
          where: u.id == ^socket.assigns.userId,
          update: [
            set: [
              currentProblems:
                fragment(
                  "jsonb_set(\"currentProblems\", ARRAY[?], ?)",
                  ^codeLang,
                  ^socket.assigns.questionId
                )
            ]
          ]
        )
        |> Repo.update_all([])
      end

      {:noreply,
       assign(socket,
         started: true,
         codeBlockIndex: codeBlockIndex,
         numRemainingBlocks: socket.assigns.numRemainingBlocks - 1,
         points: max(10, newPoints),
         code: socket.assigns.code <> "\n" <> Enum.at(socket.assigns.codeBlocks, codeBlockIndex)
       )}
    end
  end

  @impl true
  def mount(_params, session, socket) do
    is_conn = connected?(socket)

    if is_conn do
      # OnlyCodesWeb.Endpoint.subscribe("numActiveUsers")
      LiveMonitor.monitor(self())
    end

    case is_conn do
      true -> {:ok, fetch_initial_data(socket, session["current_user"].userId)}
      false -> {:ok, assign(socket, page: "loading")}
    end
  end

  @impl true
  def render(%{page: "loading"} = assigns) do
    ~L"<div class='text-center'>loading...</div>"
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(OnlyCodesWeb.PageLiveView, "ranked_live.html", assigns)
  end

  @impl true
  def handle_info({:tick, questionId}, socket) do
    if questionId == socket.assigns[:questionId] do
      if socket.assigns.numRemainingBlocks > 0 and socket.assigns.publicCorrectGitHubRepoId == "" do
        Process.send_after(self(), {:tick, questionId}, 5000)
      end

      show_another_block(socket)
    else
      {:noreply, socket}
    end
  end

  # @impl true
  # def handle_info(%{topic: "numActiveUsers", payload: payload}, socket) do
  #   {:noreply, assign(socket, numActiveUsers: payload)}
  # end

  # @impl true
  # def handle_event("showAnotherBlock", _, socket) do
  #   show_another_block(socket)
  # end

  # @impl true
  # def handle_event("showEntireCode", _, socket) do
  #   newPoints =
  #     if socket.assigns.publicCorrectGitHubRepoId != "",
  #       do: socket.assigns.points,
  #       else: 10

  #   {:noreply,
  #    assign(socket,
  #      code: Enum.join(socket.assigns.codeBlocks, "\n"),
  #      numRemainingBlocks: 0,
  #      points: newPoints
  #    )}
  # end

  @impl true
  def handle_event("onAnswer", %{"githubrepoid" => githubRepoId}, socket) do
    githubRepo =
      Enum.find(socket.assigns.answer_list, fn x ->
        x.githubRepoId == githubRepoId
      end)

    if socket.assigns.publicCorrectGitHubRepoId != "" or is_nil(githubRepo) do
      {:noreply, socket}
    else
      points =
        if githubRepoId == socket.assigns.correctGitHubRepoId,
          do: socket.assigns.points,
          else: -30

      codeLang =
        if socket.assigns.currentLang == "all languages",
          do: "all languages",
          else: socket.assigns.codeLang

      Multi.new()
      |> Multi.run(
        :one,
        fn r, _ ->
          with _ <-
                 from(u in User,
                   where: u.id == ^socket.assigns.userId,
                   update: [
                     inc: [points: ^points],
                     set: [
                       currentProblems:
                         fragment(
                           "jsonb_set(\"currentProblems\", ARRAY[?], '-1')",
                           ^codeLang
                         )
                     ]
                   ]
                 )
                 |> r.update_all([]) do
            {:ok, nil}
          end
        end
      )
      |> Multi.run(
        :two,
        fn r, _ ->
          with _ <-
                 %Choice{}
                 |> Choice.changeset(%{
                   pointsEarned: points,
                   userId: socket.assigns.userId,
                   questionId: socket.assigns.questionId,
                   guessedGitHubRepoId: githubRepo.id
                 })
                 |> r.insert!() do
            {:ok, nil}
          end
        end
      )
      |> Repo.transaction()

      {:noreply,
       assign(socket,
         guessGitHubRepoId: githubRepoId,
         publicCorrectGitHubRepoId: socket.assigns.correctGitHubRepoId
       )}
    end
  end

  @impl true
  def handle_event("update", %{"lang" => lang}, socket) do
    from(u in User,
      where: u.id == ^socket.assigns.userId,
      update: [set: [currentLang: ^lang]]
    )
    |> Repo.update_all([])

    {:noreply, fetch_initial_data(socket, socket.assigns.userId)}
  end

  @impl true
  def handle_event("nextQuestion", _, socket) do
    if socket.assigns.publicCorrectGitHubRepoId != "" do
      {:noreply, fetch_initial_data(socket, socket.assigns.userId)}
    else
      {:noreply, socket}
    end
  end
end
