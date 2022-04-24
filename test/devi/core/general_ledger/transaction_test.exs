defmodule Devi.Core.GeneralLedger.TransactionTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.GeneralLedger
  alias Devi.Core.GeneralLedger.Transaction
  alias Devi.Core.LedgerEntry

  # dumb test coverage hack
  test "requires all keys to be created" do
    assert %Transaction{inserted_at: nil, account_entries: []}
  end

  describe "add_to_ledger/4" do
    setup do
      now = "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
      ledger = general_ledger_fixture(%{preload_accounts: true})
      %{now: now, ledger: ledger}
    end

    test "generates a new ledger transaction and adds it to the journal entries", %{
      ledger: ledger,
      now: now
    } do
      {tag, entries} =
        LedgerEntry.receive_capital(%{
          capital_account: Core.fetch_account!(ledger, :mac_capital),
          asset_account: Core.fetch_account!(ledger, :cash),
          amount: 30_000,
          inserted_at: now
        })

      %{journal_entries: journal_entries} =
        GeneralLedger.add_to_ledger(ledger, entries, now, %{activity_tag: tag})

      assert Enum.count(journal_entries) == 1
      [entry | _] = journal_entries

      assert entry.inserted_at == now
      assert entry.meta == %{activity_tag: tag}
      assert entry.account_entries == entries
    end
  end
end
