Char = Object:extend()

function Char:new()
    self.isSelected = false
    self.selected = false
    self.moving = false
    self.attacking = false
    self.missed = false
    self.dodged = false
    self.attacked = false
    self.damage = 0
    self.healed = false
    self.heal = 0
    self.isAttacked = false
    self.isHealed = false
end