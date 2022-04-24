defmodule Devi.Core.LedgerEntry.OperatingActivityTest do
  use ExUnit.Case, async: true
  alias Devi.Core.LedgerEntry

  setup do
    %{now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  describe "pay_operating_expense/1" do
    test "generates ledger entries", %{now: now} do
      asset_account = %{type: :asset, id: :cash}
      expense_account = %{type: :expense, id: :rent}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.pay_operating_expense(%{
          amount: amount,
          asset_account: asset_account,
          inserted_at: now,
          expense_account: expense_account
        })

      assert activity_tag == :operating
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: expense_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "accept_liability/1" do
    test "generates ledger entries", %{now: now} do
      asset_account = %{type: :asset, id: :supplies}
      liability_account = %{type: :liability, id: :accounts_payable}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.accept_operating_liability(%{
          asset_account: asset_account,
          liability_account: liability_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :operating
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: liability_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "repay_obligation/1" do
    test "generates ledger entries", %{now: now} do
      asset_account = %{type: :asset, id: :cash}
      liability_account = %{type: :liability, id: :accounts_payable}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.repay_operating_obligation(%{
          asset_account: asset_account,
          liability_account: liability_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :operating
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: liability_account,
                 amount: amount,
                 inserted_at: now,
                 type: :decrease
               }
             end)
    end
  end
end
