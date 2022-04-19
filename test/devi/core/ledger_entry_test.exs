defmodule Devi.Core.LedgerEntryTest do
  use ExUnit.Case, async: true
  alias Devi.Core.LedgerEntry

  setup do
    %{now: "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  describe "decrease_by/3" do
    test "creates a new entry", %{now: now} do
      new_account = LedgerEntry.decrease_by(%{id: :cash, type: :asset}, 500, now)
      assert new_account.account == %{id: :cash, type: :asset}
      assert new_account.type == :decrease
      assert new_account.amount == 500
      assert new_account.inserted_at == now
    end
  end

  describe "increase_by/3" do
    test "creates a new entry", %{now: now} do
      new_account = LedgerEntry.increase_by(%{id: :cash, type: :asset}, 500, now)
      assert new_account.account == %{id: :cash, type: :asset}
      assert new_account.type == :increase
      assert new_account.amount == 500
      assert new_account.inserted_at == now
    end
  end

  describe "subtotal/1" do
    test "Reduces a list of changes to a subtotal value", %{now: now} do
      entries = [
        LedgerEntry.increase_by(%{type: :asset, id: :cash}, 5, now),
        LedgerEntry.increase_by(%{type: :asset, id: :cash}, 6, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :land}, 2, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :land}, 1, now)
      ]

      assert LedgerEntry.subtotal(entries) == 8
    end
  end

  describe "subtotal/2" do
    test "Reduces a list of changes and a default value to a subtotal value", %{now: now} do
      entries = [
        LedgerEntry.increase_by(%{type: :asset, id: :cash}, 5, now),
        LedgerEntry.increase_by(%{type: :asset, id: :cash}, 6, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :land}, 2, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :land}, 1, now)
      ]

      assert LedgerEntry.subtotal(entries, 10) == 18
    end
  end

  describe "to_subtotals/1" do
    test "Reduces a list of changes to a keyed list of subtotal values", %{now: now} do
      entries = [
        LedgerEntry.increase_by(%{type: :asset, id: :cash}, 8, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :cash}, 2, now),
        LedgerEntry.increase_by(%{type: :asset, id: :land}, 3, now),
        LedgerEntry.decrease_by(%{type: :asset, id: :land}, 1, now)
      ]

      assert LedgerEntry.to_subtotals(entries) == %{cash: 6, land: 2}
    end
  end
end
