defmodule Devi.Core.Statement.IncomeTest do
  use ExUnit.Case, async: true

  alias Devi.Core.Statement.Income
  alias Devi.LedgerFixtures

  setup do
    %{now: DateTime.from_iso8601("2022-03-03T23:50:07Z") |> elem(1)}
  end

  describe "new/1" do
    test "will generate an income statememnt", %{now: now} do
      transactions = LedgerFixtures.ledger_fixture(now)

      result = Devi.generate_income_statement(transactions)

      assert result == %Income{
               end_date: nil,
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               start_date: nil,
               total: 5300
             }
    end
  end

  describe "new/3" do
    setup args do
      Map.put(args, :then, DateTime.from_iso8601("2022-02-03T23:50:07Z") |> elem(1))
    end

    test "will generate an income statememnt", %{now: now, then: then} do
      transactions = [
        Devi.earn_asset_revenue(
          %{asset: :accounts_receivable, revenue: :service, amount: 3000},
          now
        ),
        Devi.earn_asset_revenue(%{asset: :cash, revenue: :service, amount: 5500}, now),
        Devi.earn_asset_revenue(
          %{asset: :accounts_receivable, revenue: :service, amount: 3000},
          then
        ),
        Devi.pay_expenses(%{expense: :rent, asset: :cash, amount: 2000}, now),
        Devi.pay_expenses(%{expense: :salary, asset: :cash, amount: 1200}, now)
      ]

      result = Devi.generate_income_statement(transactions, "2022-03-01", "2022-03-31")

      assert result == %Income{
               end_date: "2022-03-31",
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               start_date: "2022-03-01",
               total: 5300
             }
    end
  end
end
