defmodule Devi.Core.Statement.IncomeTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core.Account
  alias Devi.Core.Statement.Income

  setup do
    %{
      now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1),
      then: "2022-02-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1),
      begining_of_month: Date.from_iso8601!("2022-03-01"),
      end_of_month: Date.from_iso8601!("2022-03-31")
    }
  end

  describe "new/3" do
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

      state
      |> Map.put(:revenues, revenues)
      |> Map.put(:expenses, expenses)
    end

    test "will generate an income statememnt", %{
      revenues: revenues,
      expenses: expenses,
      begining_of_month: begining_of_month,
      end_of_month: end_of_month
    } do
      result =
        Devi.generate_income_statement(%{
          revenues: revenues,
          expenses: expenses,
          start_date: begining_of_month,
          end_date: end_of_month
        })

      assert result == %Income{
               end_date: end_of_month,
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               start_date: begining_of_month,
               total: 5300
             }
    end
  end
end
