defmodule Devi do
  @moduledoc """
  The basic **accounting equation** is `Assests == Liabilities + Equity`. This
  application will provide interfaces for defining these entities, recording
  their changes over time, and reporting.
  """

  alias Devi.Core

  # Transaction Creation
  defdelegate earn_asset_revenue(params, inserted_at), to: Core
  defdelegate make_contribution(params, inserted_at), to: Core
  defdelegate pay_dividend(params, inserted_at), to: Core
  defdelegate pay_expenses(params, inserted_at), to: Core
  defdelegate pay_on_account(params, inserted_at), to: Core
  defdelegate purchase_on_account(params, inserted_at), to: Core
  defdelegate purchase_with_asset(params, inserted_at), to: Core

  # Statement Creation
  defdelegate generate_income_statement(transactions, start_date, end_date), to: Core
end
