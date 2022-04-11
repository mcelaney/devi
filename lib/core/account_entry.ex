defmodule Devi.Core.AccountEntry do
  @moduledoc """
  Represents a discrete change in value on an account All amounts are recorded as
  positive integers
  """

  @typedoc """
  Denotes a role in the accounting equation

  assets = liabilities + equity
  assets = liabilities + capital + retained earnings
  assets = liabilities + capital + revenue - expense - liability
  """
  @type parent_account_type :: :asset | :capital | :dividend | :expense | :liability | :revenue

  @typedoc """
  Whether the amount is expected to add to or subtract from the given account

  We use this rather than a signed amount to remove ambiguity in algorithms
  """
  @type entry_type :: :increase | :decrease

  @typedoc """
  A two element tuple where the first element is a parent_account_type and the
  second is any representation of the account so long as it's used consistently
  in the system. Our examples show atoms like :cash or :accounts_receivable but
  it really could be any identifier. In practice it's probably an id from an Ecto
  schema from some caller.
  """
  @type account_id :: {parent_account_type, any}

  @type t :: %__MODULE__{
          account: account_id,
          amount: pos_integer,
          type: entry_type,
          inserted_at: DateTime.t()
        }

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
