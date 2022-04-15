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
  @account_types ~w[asset capital dividend expense liability revenue]a

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

  @enforce_keys ~w[account amount type inserted_at]a
  defstruct ~w[account amount type inserted_at]a

  @doc false
  @spec new(%{
          account: account_id,
          amount: pos_integer,
          type: entry_type,
          inserted_at: DateTime.t()
        }) :: t
  def new(%{
        account: {account_type, _} = account,
        amount: amount,
        type: type,
        inserted_at: inserted_at
      }) do
    unless Enum.any?(@account_types, fn at -> at == account_type end),
      do:
        raise(ArgumentError,
          message: "invalid argument account - should comply with type `account_id`"
        )

    unless type == :increase || type == :decrease,
      do:
        raise(ArgumentError,
          message: "invalid argument entry - must be `:increase` or `:decrease`"
        )

    %__MODULE__{
      account: account,
      amount: amount,
      type: type,
      inserted_at: inserted_at
    }
  end

  @doc """
  Given a list of transactions limits them to a given range between start_date 
  and end_date inclusively.

  The start_date and end_date values are expected as Strings "year-mo-da"

  # Examples

    iex> transactions = [
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
    ...> ]
    ...> Transaction.limit_by_date_range(transactions, "2022-02-01", "2022-02-28")

    [
      %Devi.Core.Transaction{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ]
  """
  @spec limit_by_date_range(list(t), String.t(), String.t()) :: list(t)
  def limit_by_date_range(transactions, start_date, end_date) do
    Enum.filter(transactions, fn transaction ->
      cond do
        DateTime.compare(transaction.inserted_at, datetime_value(:start, start_date)) == :lt ->
          false

        DateTime.compare(transaction.inserted_at, datetime_value(:end, end_date)) == :gt ->
          false

        true ->
          true
      end
    end)
  end


  defp datetime_value(_, %DateTime{} = value), do: value
  defp datetime_value(_, %Date{} = value), do: value

  defp datetime_value(:start, value),
    do: value |> Kernel.<>("T00:00:00Z") |> DateTime.from_iso8601() |> elem(1)

  defp datetime_value(:end, value),
    do: value |> Kernel.<>("T23:59:59Z") |> DateTime.from_iso8601() |> elem(1)

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
end
