
generateWorld()
player := getPlayer()
player.play()
player.setHealth(player.getHealth() - 1)
slot := player.getInventory().getInventorySlot(3)
item := createItem("Ice cream", true)
slot.setItem(item, round(slot.getMaxCapacity() / 2))