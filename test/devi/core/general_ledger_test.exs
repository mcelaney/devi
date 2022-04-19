defmodule Devi.Core.GeneralLedgerTest do
  use ExUnit.Case, async: true
  alias Devi.Core
  alias Devi.Core.GeneralLedger

  describe "creation" do
    test "sets up defaults" do
      result = %GeneralLedger{}
      assert result.journal_entries == []
      assert result.chart_of_accounts == %{}
    end
  end

  describe "add_account/2" do
    defmodule FakeAccount do
      defstruct ~w[id type]a
    end

    test "accepts a bare map" do
      ledger = Core.add_account(%GeneralLedger{}, %{id: 1, type: :asset})
      assert ledger.chart_of_accounts == %{1 => %{id: 1, type: :asset}}
    end

    test "accepte a struct" do
      ledger = Core.add_account(%GeneralLedger{}, %FakeAccount{id: 1, type: :asset})
      assert ledger.chart_of_accounts == %{1 => %FakeAccount{id: 1, type: :asset}}
    end

    test "will not allow the same account id to be registered twice" do
      ledger = Core.add_account(%GeneralLedger{}, %FakeAccount{id: 1, type: :capital})

      assert_raise ArgumentError, "This account is already registered", fn ->
        Core.add_account(ledger, %FakeAccount{id: 1, type: :dividend})
      end
    end
  end

  describe "update_account/2" do
    setup do
      %{ledger: Core.add_account(%GeneralLedger{}, %{id: 1, type: :asset, name: "old"})}
    end

    test "will update an existing account", %{ledger: ledger} do
      updated = Core.update_account(ledger, %{id: 1, type: :asset, name: "new"})
      assert updated.chart_of_accounts == %{1 => %{id: 1, type: :asset, name: "new"}}
    end

    test "will reject changes to the account type", %{ledger: ledger} do
      assert_raise ArgumentError, "The account type can not be safely changed", fn ->
        Core.update_account(ledger, %{id: 1, type: :dividend})
      end
    end
  end

  describe "fetch_acount/2" do
    setup do
      account = %{id: 1, type: :asset, name: "This account"}
      %{account: account, ledger: Core.add_account(%GeneralLedger{}, account)}
    end

    test "will return the account associated with the given id", %{
      account: account,
      ledger: ledger
    } do
      returned_account = Core.fetch_account!(ledger, account.id)
      assert returned_account == account
    end

    test "will throw an exception if not found", %{ledger: ledger} do
      assert_raise RuntimeError, "Not found", fn ->
        Core.fetch_account!(ledger, "non-existing-id")
      end
    end
  end
end
