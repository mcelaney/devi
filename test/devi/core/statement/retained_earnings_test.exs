defmodule Devi.Core.Statement.RetainedEarningsTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core.Account
  alias Devi.Core.Statement.RetainedEarnings

  setup do
    %{
      now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1),
      then: "2022-02-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1),
      begining_of_month: Date.from_iso8601!("2022-03-01"),
      end_of_month: Date.from_iso8601!("2022-03-31")
    }
  end

  describe "new/1" do
    setup(%{now: now, then: then} = state) do
      revenues = [
        account_entry_fixture(%{
          account: %Account{type: :revenue, id: :service},
          type: :increase,
          amount: 3000,
          inserted_at: now
        }),
        account_entry_fixture(%{
          account: %Account{type: :revenue, id: :service},
          type: :increase,
          amount: 5500,
          inserted_at: now
        }),
        account_entry_fixture(%{
          account: %Account{type: :revenue, id: :service},
          type: :increase,
          amount: 5500,
          inserted_at: then
        })
      ]

      expenses = [
        account_entry_fixture(%{
          account: %Account{type: :expense, id: :rent},
          type: :increase,
          amount: 2000,
          inserted_at: now
        }),
        account_entry_fixture(%{
          account: %Account{type: :expense, id: :salary},
          type: :increase,
          amount: 1200,
          inserted_at: now
        }),
        account_entry_fixture(%{
          account: %Account{type: :expense, id: :salary},
          type: :increase,
          amount: 1200,
          inserted_at: then
        })
      ]

      dividends = [
        account_entry_fixture(%{
          account: %Account{type: :dividend, id: :rent},
          type: :increase,
          amount: 500,
          inserted_at: now
        }),
        account_entry_fixture(%{
          account: %Account{type: :dividend, id: :salary},
          type: :increase,
          amount: 700,
          inserted_at: then
        })
      ]

      state
      |> Map.put(:revenues, revenues)
      |> Map.put(:expenses, expenses)
      |> Map.put(:dividends, dividends)
    end

    test "will generate an income statememnt", %{
      revenues: revenues,
      expenses: expenses,
      dividends: dividends,
      begining_of_month: begining_of_month,
      end_of_month: end_of_month
    } do
      result =
        Devi.generate_retained_earnings_statement(%{
          revenue: revenues,
          expense: expenses,
          dividend: dividends,
          start_date: begining_of_month,
          end_date: end_of_month
        })

      assert result == %RetainedEarnings{
               dividends: 500,
               end_date: end_of_month,
               ending: 8400,
               net_income: 5300,
               start_date: begining_of_month,
               starting: 3600
             }
    end
  end
end
