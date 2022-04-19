defmodule Devi.CoreFixtures do
  alias Devi.Core
  alias Devi.Core.GeneralLedger

  def general_ledger_fixture(options) do
    %GeneralLedger{}
    |> maybe_preload_accounts(options)
    |> maybe_preload_transactions(options)
    |> maybe_preload_older_transactions(options)
    |> maybe_preload_newer_transactions(options)
  end

  def maybe_preload_accounts(ledger, %{preload_accounts: true}) do
    ledger
    |> Core.add_account(%{type: :capital, id: :mac_capital})
    |> Core.add_account(%{type: :asset, id: :cash})
    |> Core.add_account(%{type: :asset, id: :land})
    |> Core.add_account(%{type: :asset, id: :supplies})
    |> Core.add_account(%{type: :liability, id: :accounts_payable})
    |> Core.add_account(%{type: :revenue, id: :service})
    |> Core.add_account(%{type: :asset, id: :accounts_receivable})
    |> Core.add_account(%{type: :expense, id: :rent})
    |> Core.add_account(%{type: :expense, id: :salary})
    |> Core.add_account(%{type: :dividend, id: :mac_dividend})
  end

  def maybe_preload_accounts(ledger, _), do: ledger

  def maybe_preload_transactions(ledger, %{transactions: true, now: now}),
    do: preload_transactions(ledger, now)

  def maybe_preload_transactions(ledger, _), do: ledger

  def maybe_preload_older_transactions(ledger, %{transactions: true, older: older}),
    do: preload_transactions(ledger, older)

  def maybe_preload_older_transactions(ledger, _), do: ledger

  def maybe_preload_newer_transactions(ledger, %{transactions: true, newer: newer}),
    do: preload_transactions(ledger, newer)

  def maybe_preload_newer_transactions(ledger, _), do: ledger

  def preload_transactions(ledger, now) do
    ledger
    |> Core.make_contribution(%{
      capital_account_id: :mac_capital,
      asset_account_id: :cash,
      amount: 30_000,
      inserted_at: now
    })
    |> Core.purchase_with_asset(%{
      from_account_id: :cash,
      to_account_id: :land,
      amount: 20_000,
      inserted_at: now
    })
    |> Core.purchase_on_account(%{
      asset_account_id: :supplies,
      liability_account_id: :accounts_payable,
      amount: 500,
      inserted_at: now
    })
    |> Core.earn_asset_revenue(%{
      asset_account_id: :cash,
      revenue_account_id: :service,
      amount: 5500,
      inserted_at: now
    })
    |> Core.earn_asset_revenue(%{
      asset_account_id: :accounts_receivable,
      revenue_account_id: :service,
      amount: 3000,
      inserted_at: now
    })
    |> Core.pay_expenses(%{
      expense_account_id: :rent,
      asset_account_id: :cash,
      amount: 2000,
      inserted_at: now
    })
    |> Core.pay_expenses(%{
      expense_account_id: :salary,
      asset_account_id: :cash,
      amount: 1200,
      inserted_at: now
    })
    |> Core.pay_on_account(%{
      asset_account_id: :cash,
      liability_account_id: :accounts_payable,
      amount: 300,
      inserted_at: now
    })
    |> Core.purchase_with_asset(%{
      from_account_id: :accounts_receivable,
      to_account_id: :cash,
      amount: 2000,
      inserted_at: now
    })
    |> Core.pay_dividend(%{
      dividend_account_id: :mac_dividend,
      asset_account_id: :cash,
      amount: 5000,
      inserted_at: now
    })
  end

  def account_fixture(ledger, item) do
    Core.fetch_account!(ledger, item)
  end
end
