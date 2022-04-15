defmodule Devi.LedgerFixtures do
  alias Devi.Core.Account

  def ledger_fixture(now) do
    owner_account = Account.new(%{type: :capital, id: :mac})
    cash_account = Account.new(%{type: :asset, id: :cash})
    land_account = Account.new(%{type: :asset, id: :land})
    supplies_account = Account.new(%{type: :asset, id: :supplies})
    accounts_payable_account = Account.new(%{type: :liability, id: :accounts_payable})
    service_account = Account.new(%{type: :revenue, id: :service})
    accounts_receivable_account = Account.new(%{type: :asset, id: :accounts_receivable})

    rent_account = Account.new(%{type: :expense, id: :rent})
    salary_account = Account.new(%{type: :expense, id: :salary})
    dividend_account = Account.new(%{type: :dividend, id: :mac})

    [
      Devi.make_contribution(
        %{capital_account: owner_account, asset_account: cash_account, amount: 30_000},
        now
      ),
      Devi.purchase_with_asset(
        %{from_account: cash_account, to_account: land_account, amount: 20_000},
        now
      ),
      Devi.purchase_on_account(
        %{
          asset_account: supplies_account,
          liability_account: accounts_payable_account,
          amount: 500
        },
        now
      ),
      Devi.earn_asset_revenue(
        %{asset_account: cash_account, revenue_account: service_account, amount: 5500},
        now
      ),
      Devi.earn_asset_revenue(
        %{
          asset_account: accounts_receivable_account,
          revenue_account: service_account,
          amount: 3000
        },
        now
      ),
      Devi.pay_expenses(
        %{expense_account: rent_account, asset_account: cash_account, amount: 2000},
        now
      ),
      Devi.pay_expenses(
        %{expense_account: salary_account, asset_account: cash_account, amount: 1200},
        now
      ),
      Devi.pay_on_account(
        %{asset_account: cash_account, liability_account: accounts_payable_account, amount: 300},
        now
      ),
      Devi.purchase_with_asset(
        %{from_account: accounts_receivable_account, to_account: cash_account, amount: 2000},
        now
      ),
      Devi.pay_dividend(
        %{dividend_account: dividend_account, asset_account: cash_account, amount: 5000},
        now
      )
    ]
  end
end
