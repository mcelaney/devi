defmodule Devi.Core do
  @moduledoc """
  A functional core for functionality provided by Devi
  """
  alias Devi.Core.Transaction

  defdelegate make_contribution(params, inserted_at), to: Transaction
  defdelegate purchase_with_asset(params, inserted_at), to: Transaction
  defdelegate purchase_on_account(params, inserted_at), to: Transaction
  defdelegate pay_on_account(params, inserted_at), to: Transaction
  defdelegate earn_asset_revenue(params, inserted_at), to: Transaction
  defdelegate pay_expenses(params, inserted_at), to: Transaction
  defdelegate pay_dividend(params, inserted_at), to: Transaction
end
