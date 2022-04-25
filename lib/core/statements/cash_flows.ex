defmodule Devi.Core.Statements.CashFlows do
  @moduledoc """
  The statement of cash flows reports the cash coming in (positive amounts) and
  the cash going out (negatve amounts) during a period. It only reports
  transations which involve cash - so any transaction which does not include cash
  (such as the purchase of land with a mortgage or the earning of accounts
  receivable revenue) will not be included in this report.

  In practive a printed Statement of Cash Flows would look something like this:

  |----------------------------------------------------------------------|
  |                        Statement of Cash Flows                       |
  |                       Month ending Nov 01, 2022                      |
  |----------------------------------------------------------------------|
  | Cash flows from operating activities:                                |
  |   Receipts:                                                          |
  |     Collections from customers:                             $ 7,500  |
  |   Payments:                                                          |
  |     For Rent:                                   $( 2,000)            |
  |     For Salaries:                                ( 1,200)            |
  |     Accounts Payable:                            (   300)            |
  |                                                 ---------   -------- |
  |   Net cash provided by operating activities:                  4,000  |
  |                                                                      |
  | Cash flows from investing activities:                                |
  |   Acquisition of land:                           (20,000)            |
  |                                                 ---------            |
  |   Net cash provided by investing activities:                (20,000) |
  |                                                                      |
  | Cash froms from financing activities:                                |
  |   Issued Common Stock:                            30,000             |
  |   Payment of Cash Dividends:                     ( 5,000)            |
  |                                                 ---------            |
  |     Net cash provided by financing activities:               25,000  |
  |                                                             -------- |
  |                                                               9,000  |
  | Cash balance November 1, 2016                                     0  |
  |                                                             -------- |
  | Cash balance November 30, 2016                              $ 9,000  |
  |                                                             ======== |
  |----------------------------------------------------------------------|

  So we provide the values in a struct:

  %Devi.Core.Statement.CashFlows{
    operating: %{
      expense: %{
        accounts_payable: -300,
        rent: -2000,
        salaries: -1200
      },
      revenue: %{
        accounts_receivable: 2000,
        service: 5500
      },
      total: 4000
    },
    investing: %{
      assets: %{
        land: -20_000
      },
      total: -20_000
    },
    financing: %{
      capital: %{
        mac_capital: 30_000,
      },
      dividends: %{
        mac_dividend: -5000
      },
      total: 25_000
    }
    sub_total: 9000,
    period_start: ~D[2022-11-01],
    period_start_balance: 0,
    period_end: ~D[2022-11-30],
    period_end_balance: 9000
  }
  """

  alias Devi.Core.GeneralLedger
  alias Devi.Core.LedgerEntry
  alias Devi.Core.PeriodLedger

  @type account_type :: GeneralLedger.account_type()
  @type account_id :: GeneralLedger.account_type()

  @type t :: %__MODULE__{
          operating: %{
            expense: %{optional(any) => list(%{account: account_type, amount: integer})},
            revenue: %{optional(any) => list(%{account: account_type, amount: integer})},
            total: integer
          },
          investing: %{
            assets: %{optional(any) => list(%{account: account_type, amount: integer})},
            total: integer
          },
          financing: %{
            capital: %{optional(any) => list(%{account: account_type, amount: integer})},
            dividend: %{optional(any) => list(%{account: account_type, amount: integer})},
            total: integer
          },
          total: integer,
          period_start: Date.t(),
          period_start_balance: integer,
          period_end: Date.t(),
          period_end_balance: integer
        }

  defstruct ~w[operating investing financing total period_start period_start_balance period_end period_end_balance]a

  @spec new(%{cash_id: account_id, history: PeriodLedger.t(), period: PeriodLedger.t()}) :: t
  def new(%{
        cash_id: cash_id,
        history: %PeriodLedger{} = history_ledger,
        period: %PeriodLedger{} = period_ledger
      }) do
    report = report_data(cash_id, history_ledger, period_ledger)

    %__MODULE__{
      operating: %{
        expense: report[:expense],
        revenue: report[:revenue],
        total: sum_all(report[:revenue]) + sum_all(report[:expense])
      },
      investing: %{
        assets: report[:assets],
        total: sum_all(report[:assets])
      },
      financing: %{
        capital: report[:capital],
        dividend: report[:dividend],
        total: sum_all(report[:capital]) + sum_all(report[:dividend])
      },
      total: report[:sub_total],
      period_start: period_ledger.period_start,
      period_start_balance: report[:period_start_balance],
      period_end: period_ledger.period_end,
      period_end_balance: report[:sub_total] + report[:period_start_balance]
    }
  end

  defp report_data(cash_id, history_ledger, period_ledger) do
    activity_ledger = group_cash_transactions_by_activity_tag(period_ledger, cash_id)

    financing_activity =
      activity_ledger
      |> Map.get(:financing, [])
      |> Enum.group_by(fn %{account: %{type: type}} -> type end)

    %{
      expense: Map.get(activity_ledger, :operating, []),
      revenue: Map.get(activity_ledger, :collecting, []),
      assets: Map.get(activity_ledger, :investing, []),
      capital: Map.get(financing_activity, :capital, []),
      dividend: Map.get(financing_activity, :dividend, [])
    }
    |> add_subtotals(history_ledger, cash_id)
  end

  defp add_subtotals(token, history_ledger, cash_id) do
    sub_total =
      token[:revenue]
      |> sum_all()
      |> Kernel.+(sum_all(token[:expense]))
      |> Kernel.+(sum_all(token[:assets]))
      |> Kernel.+(sum_all(token[:capital]))
      |> Kernel.+(sum_all(token[:dividend]))

    period_start_balance =
      history_ledger.asset |> LedgerEntry.to_subtotals() |> Map.get(cash_id, 0)

    token
    |> Map.put(:sub_total, sub_total)
    |> Map.put(:period_start_balance, period_start_balance)
  end

  defp sum_all(entries) do
    Enum.reduce(entries, 0, fn %{amount: amount}, acc -> amount + acc end)
  end

  defp group_cash_transactions_by_activity_tag(%{journal_entries: journal_entries}, cash_id) do
    journal_entries
    |> Enum.filter(fn
      %{account_entries: entries} -> has_cash_account_entry?(entries, cash_id)
    end)
    |> Enum.group_by(fn %{meta: %{activity_tag: tag}} -> tag end)
    |> Map.new(fn {activity, transactions} ->
      {
        activity,
        to_cash_entries(transactions, cash_id)
      }
    end)
  end

  defp to_cash_entries(transactions, cash_id) do
    Enum.reduce(transactions, [], fn %{account_entries: entries}, tranformed ->
      tranformed_entry = build_report_entry(entries, cash_id)
      [tranformed_entry | tranformed]
    end)
  end

  defp build_report_entry(entries, cash_id) do
    Enum.reduce(
      entries,
      %{amount: 0, account: nil},
      fn %{account: account, type: type, amount: amount}, acc ->
        cond do
          account.id == cash_id && type == :increase ->
            %{acc | amount: amount}

          account.id == cash_id && type == :decrease ->
            %{acc | amount: 0 - amount}

          true ->
            %{acc | account: account}
        end
      end
    )
  end

  defp has_cash_account_entry?(entries, cash_id) do
    Enum.any?(entries, fn %{account: %{id: id}} -> id == cash_id end)
  end
end
