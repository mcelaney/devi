defmodule Devi.Core.Transaction.CreateCommandsTest do
  use ExUnit.Case, async: true
  alias Devi.Core
  alias Devi.Core.AccountEntry

  setup do
    %{now: DateTime.from_iso8601("2022-03-03T23:50:07Z") |> elem(1)}
  end

  describe "make_contribution/2" do
    test "creates an increase to capital and asset accounts", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.make_contribution(%{owner: :mac, asset: :cash, amount: 30000}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:capital, :mac},
                 amount: 30000,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 30000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_with_asset/2" do
    test "decreases an asset account and increases another", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.purchase_with_asset(%{from: :cash, to: :land, amount: 20000}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 20000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :land},
                 amount: 20000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_on_account/2" do
    test "increases an asset account as well as a liability account", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.purchase_on_account(
          %{asset: :supplies, account: :accounts_payable, amount: 500},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:liability, :accounts_payable},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :supplies},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "earn_asset_revenue/2" do
    test "increases an asset account and a revenue account", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.earn_asset_revenue(%{asset: :cash, revenue: :service, amount: 5500}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:revenue, :service},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_on_account/2" do
    test "decreases an asset account as well as a liability account", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.pay_on_account(%{asset: :cash, payment: :accounts_payable, amount: 300}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:liability, :accounts_payable},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               }
             end)
    end
  end

  describe "pay_expenses/2" do
    test "decreases an asset account and increases an expense account", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.pay_expenses(%{expense: :rent, asset: :cash, amount: 2000}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:expense, :rent},
                 amount: 2000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_dividend/2" do
    test "decreases an asset account and increases a dividend account", %{now: now} do
      %{account_entries: entries, inserted_at: inserted_at} =
        Core.pay_dividend(%{dividend: :dividend, asset: :cash, amount: 5000}, now)

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:asset, :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: {:dividend, :dividend},
                 amount: 5000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end
end
