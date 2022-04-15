defmodule Devi.Core.Account do
  @moduledoc """
  A record of the changes in value of a part of the accounting equation

  This struct is intended to serve as an internal guide - in practice callers
  would have their own Account implementations that include `account_type` and
  `id` as keys - but we avoid pattern patching on this specific type.
  """

  @typedoc """
  Denotes a role in the accounting equation

  assets = liabilities + equity
  assets = liabilities + (capital + retained earnings)
  assets = liabilities + (capital + (revenue - expense - dividend))
  """
  @type account_type :: :asset | :capital | :dividend | :expense | :liability | :revenue
  @account_types ~w[asset capital dividend expense liability revenue]a

  @type t :: %__MODULE__{
          type: account_type,
          id: any
        }

  @enforce_keys ~w[type id]a
  defstruct ~w[type id]a

  def new(%{__struct__: _, type: _type, id: _id} = account), do: account

  def new(%{type: type, id: id}) do
    validate_account_type(type)
    %__MODULE__{type: type, id: id}
  end

  defp validate_account_type(type) do
    unless Enum.any?(@account_types, fn at -> at == type end),
      do:
        raise(ArgumentError,
          message:
            "invalid type - should be one of :asset | :capital | :dividend | :expense | :liability | :revenue"
        )
  end
end
