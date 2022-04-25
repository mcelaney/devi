defmodule Devi.Core.Formula do
  @moduledoc """
  Arbitrary value calculators
  """
  alias Devi.Core.PeriodLedger

  @doc """
  A measure of how profitably a company uses it's assets.

  average assets = (beginning total assets + ending total assets) / 2
  ROA = net income / average assets
  """
  @spec return_on_assets(%{history: PeriodLedger.t(), period: PeriodLedger.t()}) :: float
  def return_on_assets(%{
        history: %PeriodLedger{} = history_ledger,
        period: %PeriodLedger{} = period_ledger
      }) do
    net_income = net_income(period_ledger)
    average_assets = average_assets(history_ledger, period_ledger)

    net_income
    |> Decimal.new()
    |> Decimal.div(average_assets)
    |> Decimal.round(3)
    |> Decimal.to_float()
  end

  defp average_assets(history_ledger, period_ledger) do
    %{asset: starting} = PeriodLedger.fetch_totals(history_ledger, [:asset])
    %{asset: in_period} = PeriodLedger.fetch_totals(period_ledger, [:asset])

    starting
    |> Kernel.+(in_period)
    |> Decimal.div(2)
  end

  defp net_income(ledger) do
    %{revenue: revenues, expense: expenses} =
      PeriodLedger.fetch_totals(ledger, [:revenue, :expense])

    revenues - expenses
  end
end
