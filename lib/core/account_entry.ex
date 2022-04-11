defmodule Devi.Core.AccountEntry do
  defstruct ~w[account amount type inserted_at]a

  def new(%{account: account, amount: amount, type: type, inserted_at: inserted_at}) do
    %__MODULE__{
      account: account,
      amount: amount,
      type: type,
      inserted_at: inserted_at
    }
  end

  def subtotal(changes, initial_value \\ 0) do
    Enum.reduce(changes, initial_value, fn
      %{amount: amount, type: :increase}, acc -> acc + amount
      %{amount: amount, type: :decrease}, acc -> acc - amount
    end)
  end
end
