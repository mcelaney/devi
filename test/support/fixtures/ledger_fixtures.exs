defmodule Devi.LedgerFixtures do
  def ledger_fixture(now) do
    [
      Devi.make_contribution(%{owner: :mac, asset: :cash, amount: 30_000}, now),
      Devi.purchase_with_asset(%{from: :cash, to: :land, amount: 20_000}, now),
      Devi.purchase_on_account(
        %{asset: :supplies, account: :accounts_payable, amount: 500},
        now
      ),
      Devi.earn_asset_revenue(%{asset: :cash, revenue: :service, amount: 5500}, now),
      Devi.earn_asset_revenue(
        %{asset: :accounts_receivable, revenue: :service, amount: 3000},
        now
      ),
      Devi.pay_expenses(%{expense: :rent, asset: :cash, amount: 2000}, now),
      Devi.pay_expenses(%{expense: :salary, asset: :cash, amount: 1200}, now),
      Devi.pay_on_account(%{asset: :cash, payment: :accounts_payable, amount: 300}, now),
      Devi.purchase_with_asset(
        %{from: :accounts_receivable, to: :cash, amount: 2000},
        now
      ),
      Devi.pay_dividend(%{dividend: :dividend, asset: :cash, amount: 5000}, now)
    ]
  end
end
