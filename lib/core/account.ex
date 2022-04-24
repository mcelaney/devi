defmodule Devi.Core.Account do
  @moduledoc """
  A record of the changes in value of a part of the accounting equation

  A valid account need only be a struct or map that has an `id` and a `type`
  field - in practice callers would be expected to have their own Account
  implementations.
  """

  @typedoc """
  Denotes a role in the accounting equation

  assets = liabilities + equity
  equity = capital + retained earnings
  retained earnings = revenue - expense - dividend
  """
  @type account_type :: :asset | :capital | :dividend | :expense | :liability | :revenue
  @type id_type :: any

  @typedoc """
  Any struct can be used as an account so long as it has a `:type` and an `:id`
  """
  @type t :: %{type: account_type, id: any}

  @account_types ~w[asset capital dividend expense liability revenue]a
  def account_types, do: @account_types
end
