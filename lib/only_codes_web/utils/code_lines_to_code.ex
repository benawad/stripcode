defmodule OnlyCodes.Utils do
  def maybe_inc(s, i) do
    if String.trim(s) != "", do: i - 1, else: i
  end

  @spec code_lines_to_code(list(String.t()), number) :: String.t()
  def code_lines_to_code(codeLines, n) do
    codeLines
    |> Enum.reduce_while({"", n}, fn cv, {s, i} ->
      if i > 0, do: {:cont, {s <> cv <> "\n", maybe_inc(cv, i)}}, else: {:halt, {s, i}}
    end)
    |> elem(0)
    |> String.trim()
  end

  # def _code_lines_to_next_block (s, cv, i, block_size) do
  #   if block_size > 0 and String.trim(cv) == "" do

  #   end
  # end

  # @spec code_lines_to_next_block(list(String.t()), number) :: String.t()
  # def code_lines_to_next_block(codeLines, i) do
  #   codeLines
  #   |> Enum.reduce_while({"", 0, 0}, fn cv, {s, k, block_size} ->
  #     if k < i, do: {:cont, {"", k + 1, block_size}}, else: {:cont, {s, i}}
  #   end)
  # end
end
