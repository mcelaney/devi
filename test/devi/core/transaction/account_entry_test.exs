defmodule Devi.Core.AccountEntryTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core.AccountEntry

  describe "new/1" do
    setup do
      %{
        asset_params: account_entry_attributes(%{account: {:asset, "any"}}),
        capital_params: account_entry_attributes(%{account: {:capital, "any"}}),
        dividend_params: account_entry_attributes(%{account: {:dividend, "any"}}),
        expense_params: account_entry_attributes(%{account: {:expense, "any"}}),
        liability_params: account_entry_attributes(%{account: {:liability, "any"}}),
        revenue_params: account_entry_attributes(%{account: {:revenue, "any"}})
      }
    end

    test "allows asset types", %{asset_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "allows capital types", %{capital_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "allows dividend types", %{dividend_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "allows expense types", %{expense_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "allows liability types", %{liability_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "allows revenue types", %{revenue_params: params} do
      assert %AccountEntry{} = AccountEntry.new(params)
    end

    test "Will reject other parent account types" do
      assert_raise ArgumentError, fn ->
        %{account: {:anything_else, "any"}}
        |> account_entry_attributes()
        |> AccountEntry.new()
      end
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
        account_entry_fixture(%{account: {:asset, "any"}, amount: 5, type: :increase}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 6, type: :increase}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 2, type: :decrease}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 1, type: :decrease})
      ]

      assert AccountEntry.subtotal(entries) == 8
    end
  end

  describe "subtotal/2" do
    test "Reduces a list of changes and a default value to a subtotal value" do
      entries = [
        account_entry_fixture(%{account: {:asset, "any"}, amount: 5, type: :increase}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 6, type: :increase}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 2, type: :decrease}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 1, type: :decrease})
      ]

      assert AccountEntry.subtotal(entries, 10) == 18
    end
  end

  describe "to_subtotals/1" do
    test "Reduces a list of changes to a keyed list of subtotal values" do
      entries = [
        account_entry_fixture(%{account: {:asset, "any"}, amount: 8, type: :increase}),
        account_entry_fixture(%{account: {:asset, "any"}, amount: 2, type: :decrease}),
        account_entry_fixture(%{account: {:asset, "other"}, amount: 3, type: :increase}),
        account_entry_fixture(%{account: {:asset, "other"}, amount: 1, type: :decrease})
      ]

      assert AccountEntry.to_subtotals(entries) == %{"any" => 6, "other" => 2}
    end
  end
end
