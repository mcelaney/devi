defmodule Devi.Core.LedgerEntry.CollectingActivityTest do
  use ExUnit.Case, async: true
  alias Devi.Core.LedgerEntry

  setup do
    %{now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  describe "receive_revenue/1" do
    test "generates ledger entries", %{now: now} do
      asset_account = %{type: :asset, id: :cash}
      revenue_account = %{type: :revenue, id: :service}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.receive_revenue(%{
          asset_account: asset_account,
          revenue_account: revenue_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :collecting
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
                 account: revenue_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "receive_payment_on_account/1" do
    test "generates ledger entries", %{now: now} do
      receivable_account = %{type: :asset, id: :account_receivable}
      asset_account = %{type: :asset, id: :cash}
      amount = 500

      {activity_tag, entries} =
        LedgerEntry.receive_payment_on_account(%{
          receivable_account: receivable_account,
          asset_account: asset_account,
          amount: amount,
          inserted_at: now
        })

      assert activity_tag == :collecting
      assert Enum.count(entries) == 2

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: receivable_account,
                 amount: amount,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: asset_account,
                 amount: amount,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end
end
