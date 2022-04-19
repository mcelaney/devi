defmodule Devi.Core.Statements.BalanceSheet do
  @moduledoc """
  Also called the statement of financial position - the balance sheet is a
  snapshot of the entity menat to allow a stakeholder to quickly assess the
  overall health of the company. It provides the Assets, Liabilities, and Equity
  for a company as of a specific date (usually the end of a month, quarter, or
  year)

  In practice a printed Balance Sheet statement would look something like this:

  |---------------------------------------------------------------------------------|
  |                                  Balance Sheet                                  |
  |                                    2022/11/30                                   |
  |---------------------------------------------------------------------------------|
  |                  Assets                |               Liabilities              |
  | Cash                           $  9000 | Accounts Payable               $   200 |
  | Accounts Receivable               1000 |                                        |
  | Office Supplies                    500 |          Stockholders' Equity          |
  | Land                            20,000 | Common Stock                    30,000 |
  |                                        | Retained Earnings                  300 |
  |                                        |                                ------- |
  |                                        | Total Stockholder's Equity      30,300 |
  |                                        |                                        |
  |                                ------- |                                ------- |
  |                                $30,500 | Total Liabilities and Equity   $30,500 |
  |                                ======= |                                ======= |
  |---------------------------------------------------------------------------------|

  So we provide the values in a struct:

  %Devi.Core.Statement.BalanceSheet{
    asset_sheet: %{
      assets: %{
        cash: 9000,
        accounts_receivable: 1000,
        office_supplies: 500,
        land: 20_000
      },
      total: 30_500
    },
    equity_liability_sheet: %{
      liability: %{
        liabilities: %{
          accounts_payable: 200
        },
        total: 200
      },
      equity: %{
        capital: %{
          common_stock: 30_000
        },
        capital_subtotal: 30_000,
        retained_earnings: %{
          revenues: 8500,
          expenses: 3200,
          dividends: 5000
        },
        retained_earnings_subtotal: 300,
        total: 30_300,
      },
      total: 30_500
    },
    period_end: ~D[2022-11-01]
  }
  """
  alias Devi.Core
  alias Devi.Core.PeriodLedger

  @type t :: %__MODULE__{
          asset_sheet: %{
            asset: %{optional(any) => non_neg_integer},
            total: non_neg_integer
          },
          equity_liability_sheet: %{
            liability: %{
              liabilities: %{optional(any) => non_neg_integer},
              total: non_neg_integer
            },
            equity: %{
              capital: %{optional(any) => non_neg_integer},
              capital_subtotal: non_neg_integer,
              retained_earnings: %{optional(any) => non_neg_integer},
              retained_earnings_subtotal: non_neg_integer,
              total: non_neg_integer
            },
            total: non_neg_integer
          },
          period_end: Date.t()
        }

  defstruct ~w[asset_sheet equity_liability_sheet period_end]a

  def new(%PeriodLedger{} = period_ledger) do
    sub_totals = PeriodLedger.fetch_sub_totals(period_ledger, Core.account_types())
    totals = PeriodLedger.fetch_totals(period_ledger, Core.account_types())
    retained_earnings = totals[:revenue] - totals[:expense] - totals[:dividend]

    %__MODULE__{
      asset_sheet: %{
        assets: sub_totals[:asset],
        total: totals[:asset]
      },
      equity_liability_sheet: %{
        liability: %{
          liabilities: sub_totals[:liability],
          total: totals[:liability]
        },
        equity: %{
          capital: sub_totals[:capital],
          capital_subtotal: totals[:capital],
          retained_earnings: %{
            dividends: totals[:dividend],
            expenses: totals[:expense],
            revenues: totals[:revenue]
          },
          retained_earnings_subtotal: retained_earnings,
          total: retained_earnings + totals[:capital]
        },
        total: retained_earnings + totals[:capital] + totals[:liability]
      },
      period_end: period_ledger.period_end
    }
  end
end
