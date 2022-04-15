defmodule Devi.Core.AccountEntry do
  @moduledoc """
  Represents a discrete change in value on an account All amounts are recorded as
  positive integers
  """

  alias Devi.Core.Account

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

  @type t :: %__MODULE__{
          account: Account.t(),
          amount: pos_integer,
          type: entry_type,
          inserted_at: DateTime.t()
        }

  @enforce_keys ~w[account amount type inserted_at]a
  defstruct ~w[account amount type inserted_at]a

  @doc false
  @spec new(%{
          account: Account.t(),
          amount: pos_integer,
          type: entry_type,
          inserted_at: DateTime.t()
        }) :: t
  def new(%{account: account, amount: amount, type: type, inserted_at: inserted_at}) do
    validated_account = Account.new(account)
    validate_type(type)

    %__MODULE__{
      account: validated_account,
      amount: amount,
      type: type,
      inserted_at: inserted_at
    }
  end

  defp validate_type(type) do
    unless type == :increase || type == :decrease,
      do:
        raise(ArgumentError,
          message: "invalid argument entry - must be `:increase` or `:decrease`"
        )
  end

  @doc """
  Reduces a list of changes to a subtotal value.

  # Examples

    iex> entries = [
    ...>   %AccountEntry{amount: 5500, type: :increase, ...},
    ...>   %AccountEntry{amount: 3000, type: :decrese, ...}
    ...> ]
    ...> AccountEntry.subtotal(entries)
    2500

    iex> entries = [
    ...>   %AccountEntry{amount: 5500, type: :increase, ...},
    ...>   %AccountEntry{amount: 3000, type: :decrese, ...}
    ...> ]
    ...> AccountEntry.subtotal(entries, 500)
    3000    
  """
  @spec subtotal(list(t), non_neg_integer) :: non_neg_integer
  def subtotal(changes, initial_value \\ 0) do
    Enum.reduce(changes, initial_value, fn
      %{amount: amount, type: :increase}, acc -> acc + amount
      %{amount: amount, type: :decrease}, acc -> acc - amount
    end)
  end

  @doc """
  Reduces a list of account entries to a keyed list of subtotal values

  # Examples

    iex> entries = [
    ...>   %AccountEntry{account: {:asset, "any"}, amount: 8, type: :increase, ...},
    ...>   %AccountEntry{account: {:asset, "any"}, amount: 2, type: :decrease, ...},
    ...>   %AccountEntry{account: {:asset, "other"}, amount: 3, type: :increase, ...},
    ...>   %AccountEntry{account: {:asset, "other"}, amount: 1, type: :decrease, ...},
    ...> ]
    ...> AccountEntry.to_subtotals(entries)
    %{"any" => 6, "other" => 2}
  """
  @spec to_subtotals(list(t)) :: map
  def to_subtotals(account_entries) do
    account_entries
    |> Enum.group_by(fn %{account: %{id: account}} -> account end)
    |> Map.new(fn {account, entries} ->
      {
        account,
        subtotal(entries)
      }
    end)
  end
end
