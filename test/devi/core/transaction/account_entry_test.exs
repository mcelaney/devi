defmodule Devi.Core.AccountEntryTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core.AccountEntry

  describe "new/1" do
    test "will create a new account entry" do
      assert %AccountEntry{} = AccountEntry.new(account_entry_attributes())
    end

    test "Will reject bad account entry types" do
      assert_raise ArgumentError, fn ->
        %{type: :not_increase_or_decrease}
        |> account_entry_attributes()
        |> AccountEntry.new()
      end
    end
  end

  describe "subtotal/1" do
    test "Reduces a list of changes to a subtotal value" do
      entries = [
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 5, type: :increase}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 6, type: :increase}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 2, type: :decrease}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 1, type: :decrease})
      ]

      assert AccountEntry.subtotal(entries) == 8
    end
  end

  describe "subtotal/2" do
    test "Reduces a list of changes and a default value to a subtotal value" do
      entries = [
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 5, type: :increase}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 6, type: :increase}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 2, type: :decrease}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 1, type: :decrease})
      ]

      assert AccountEntry.subtotal(entries, 10) == 18
    end
  end

  describe "to_subtotals/1" do
    test "Reduces a list of changes to a keyed list of subtotal values" do
      entries = [
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 8, type: :increase}),
        account_entry_fixture(%{account: asset_account_fixture("any"), amount: 2, type: :decrease}),
        account_entry_fixture(%{
          account: asset_account_fixture("other"),
          amount: 3,
          type: :increase
        }),
        account_entry_fixture(%{
          account: asset_account_fixture("other"),
          amount: 1,
          type: :decrease
        })
      ]

      assert AccountEntry.to_subtotals(entries) == %{"any" => 6, "other" => 2}
    end
  end
end
