-- imports
local Utilities = require "utilities.utilities"
local Command_controller = require "python_AI.commands.command_controller"



-- World_data_builder
local World_data_builder = {}
World_data_builder.entities = nil
World_data_builder.all_units = nil
---@type CDOTA_BaseNPC_Hero
World_data_builder.requesting_hero = nil
---@type integer
World_data_builder.requesting_team = nil


---@param unit_data table
---@param unit_entity CDOTA_BaseNPC
function World_data_builder:Insert_base_unit_data(unit_data, unit_entity)
    local attackTarget = unit_entity:GetAttackTarget()
    if attackTarget then
        unit_data.attackTarget = tostring(attackTarget:entindex())
    end
    unit_data.level = unit_entity:GetLevel()
    unit_data.origin = Utilities:Vector_to_array(unit_entity:GetOrigin())
    unit_data.health = unit_entity:GetHealth()
    unit_data.maxHealth = unit_entity:GetMaxHealth()
    unit_data.mana = unit_entity:GetMana()
    unit_data.maxMana = unit_entity:GetMaxMana()
    unit_data.alive = unit_entity:IsAlive()
    unit_data.blind = unit_entity:IsBlind()
    unit_data.dominated = unit_entity:IsDominated()
    unit_data.deniable = unit_entity:Script_IsDeniable()
    unit_data.disarmed = unit_entity:IsDisarmed()
    unit_data.rooted = unit_entity:IsRooted()
    unit_data.name = unit_entity:GetName()
    unit_data.team = unit_entity:GetTeamNumber()
    unit_data.attackRange = unit_entity:Script_GetAttackRange()
    unit_data.attackDamage = unit_entity:GetAttackDamage()
    unit_data.forwardVector = Utilities:Vector_to_array(unit_entity:GetForwardVector())
    unit_data.isAttacking = unit_entity:IsAttacking()
    unit_data.magicimmune = unit_entity:IsMagicImmune()
end

---@param unit_entity CDOTA_BaseNPC
---@return table items
function World_data_builder:Get_items_data(unit_entity)
    local items = {}
    for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9, 1 do
        local item = unit_entity:GetItemInSlot(i)
        items[i] = {}
        if item then
            items[i].name = item:GetName()
            items[i].slot = item:GetItemSlot()
            items[i].charges = item:GetCurrentCharges()
            items[i].castRange = item:GetCastRange()
            items[i].combineLocked = item:IsCombineLocked()
            items[i].disassemblable = Command_controller:Hero_can_disassemble_item(item)
            items[i].cooldownTimeRemaining = item:GetCooldownTimeRemaining()
        end
    end
    return items
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return boolean
function World_data_builder:Has_tower_aggro(hero_entity)
    for _index, unit in ipairs(self.all_units) do
        if unit:IsTower() and unit:IsAlive() then
            ---@type table
            local aggro_target = unit:GetAggroTarget()
            if aggro_target == hero_entity then
                return true
            end
        end
    end
    return false
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return boolean
function World_data_builder:Has_aggro(hero_entity)
    for _index, unit in ipairs(self.all_units) do
        ---@type table
        local aggro_target = unit:GetAggroTarget()
        if aggro_target == hero_entity then
            return true
        end
    end
    return false
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return integer
function World_data_builder:Get_hero_ability_count(hero_entity)
    return hero_entity:GetAbilityCount() - 1 --minus 1 because lua for loops are upper boundary inclusive
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return table abilities
function World_data_builder:Get_hero_abilities(hero_entity)
    local abilities = {}

    local hero_ability_key = hero_entity:GetName() .. hero_entity:GetTeam()
    for index, ability_entity in pairs(Settings.accessible_abilities[hero_ability_key]) do
        abilities[index] = {}
        abilities[index].type = "Ability"
        abilities[index].name = ability_entity:GetAbilityName()
        abilities[index].targetFlags = ability_entity:GetAbilityTargetFlags()
        abilities[index].targetTeam = ability_entity:GetAbilityTargetTeam()
        abilities[index].targetType = ability_entity:GetAbilityTargetType()
        abilities[index].abilityType = ability_entity:GetAbilityType()
        abilities[index].abilityIndex = ability_entity:GetAbilityIndex()
        abilities[index].level = ability_entity:GetLevel()
        abilities[index].maxLevel = ability_entity:GetMaxLevel()
        abilities[index].abilityDamage = ability_entity:GetAbilityDamage()
        abilities[index].abilityDamageType = ability_entity:GetAbilityDamageType()
        abilities[index].cooldownTimeRemaining = ability_entity:GetCooldownTimeRemaining()
        abilities[index].behavior = ability_entity:GetBehavior()
        abilities[index].toggleState = ability_entity:GetToggleState()
        abilities[index].manaCost = ability_entity:GetManaCost(ability_entity:GetLevel())
        abilities[index].heroLevelRequiredToLevelUp = ability_entity:GetHeroLevelRequiredToUpgrade()
    end

    return abilities
end

---@param hero_data any
---@param hero_entity CDOTA_BaseNPC_Hero
function World_data_builder:Insert_tp_scroll_data(hero_data, hero_entity)
    hero_data.tpScrollAvailable = false
    hero_data.tpScrollCooldownTime = 0.
    hero_data.tpScrollCharges = 0

    local scroll_item_entity = hero_entity:GetItemInSlot(DOTA_ITEM_TP_SCROLL)
    if scroll_item_entity then
        hero_data.tpScrollAvailable = scroll_item_entity:IsCooldownReady()
        hero_data.tpScrollCooldownTime = scroll_item_entity:GetCooldownTime()
        hero_data.tpScrollCharges = scroll_item_entity:GetCurrentCharges()
    end
end

---@param hero_data table
---@param hero_entity CDOTA_BaseNPC_Hero
function World_data_builder:Insert_base_hero_data(hero_data, hero_entity)
    hero_data.type = "Hero"
    hero_data.hasTowerAggro = self:Has_tower_aggro(hero_entity)
    hero_data.hasAggro = self:Has_aggro(hero_entity)
    hero_data.deaths = hero_entity:GetDeaths()
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return table
function World_data_builder:Get_stash_items_data(hero_entity)
    local items = {}
    for i = DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6, 1 do
        local item = hero_entity:GetItemInSlot(i)
        items[i] = {}
        if item then
            items[i].name = item:GetName()
            items[i].slot = item:GetItemSlot()
            items[i].charges = item:GetCurrentCharges()
            items[i].castRange = item:GetCastRange()
            items[i].combineLocked = item:IsCombineLocked()
            items[i].disassemblable = Command_controller:Hero_can_disassemble_item(item)
            items[i].cooldownTimeRemaining = item:GetCooldownTimeRemaining()
        end
    end
    return items
end

---@param hero_data table
---@param hero_entity CDOTA_BaseNPC_Hero
function World_data_builder:Insert_player_hero_data(hero_data, hero_entity)
    hero_data.type = "PlayerHero"

    hero_data.denies = hero_entity:GetDenies()
    hero_data.xp = hero_entity:GetCurrentXP()
    hero_data.gold = hero_entity:GetGold()
    hero_data.abilityPoints = hero_entity:GetAbilityPoints()
    hero_data.courier_id = tostring(PlayerResource:GetPreferredCourierForPlayer(hero_entity:GetPlayerOwnerID()):entindex())
    hero_data.buybackCost = hero_entity:GetBuybackCost(false)
    hero_data.buybackCooldownTime = hero_entity:GetBuybackCooldownTime()
    hero_data.items = self:Get_items_data(hero_entity)
    hero_data.stashItems = self:Get_stash_items_data(hero_entity)
    hero_data.inRangeOfHomeShop = hero_entity:IsInRangeOfShop(DOTA_SHOP_HOME, true)
    hero_data.inRangeOfSecretShop = hero_entity:IsInRangeOfShop(DOTA_SHOP_SECRET, true)

    self:Insert_tp_scroll_data(hero_data, hero_entity)

    hero_data.abilities = self:Get_hero_abilities(hero_entity)
end

---@param courier_data table
---@param courier_entity CDOTA_BaseNPC
function World_data_builder:Insert_courier_data(courier_data, courier_entity)
    courier_data.type = "Courier"
    courier_data.items = self:Get_items_data(courier_entity)
    courier_data.inRangeOfHomeShop = courier_entity:IsInRangeOfShop(DOTA_SHOP_HOME, true)
    courier_data.inRangeOfSecretShop = courier_entity:IsInRangeOfShop(DOTA_SHOP_SECRET, true)
end

---@param unit_entity CDOTA_BaseNPC
---@return table unit_data
function World_data_builder:Get_unit_data(unit_entity)
    local unit_data = {}
    self:Insert_base_unit_data(unit_data, unit_entity)

    if unit_entity:IsHero() then
        self:Insert_base_hero_data(unit_data, unit_entity)

        if self.requesting_team == unit_entity:GetTeam() then
            self:Insert_player_hero_data(unit_data, unit_entity)
        end

    elseif unit_entity:IsBuilding() then
        if unit_entity:IsTower() then
            unit_data.type = "Tower"
        else
            unit_data.type = "Building"
        end
    elseif unit_entity:IsCourier() then
        self:Insert_courier_data(unit_data, unit_entity)
    else
        unit_data.type = "BaseNPC"
    end

    return unit_data
end

---@param tree_entity table
---@return table tree_data
function World_data_builder:Get_tree_data(tree_entity)
    local tree_data = {}
    tree_data.origin = Utilities:Vector_to_array(tree_entity:GetOrigin())
    tree_data.type = "Tree"
    return tree_data
end

function World_data_builder:Insert_trees()
    local tree_entity = Entities:FindByClassname(nil, "ent_dota_tree")
    while tree_entity ~= nil do
        if IsLocationVisible(self.requesting_hero:GetTeam(), tree_entity:GetOrigin()) and tree_entity:IsStanding() then
            self.entities[tree_entity:entindex()] = self:Get_tree_data(tree_entity)
        end
        tree_entity = Entities:FindByClassname(tree_entity, "ent_dota_tree")
    end
end

---@param rune_entity table
---@return table tree_data
function World_data_builder:Get_rune_data(rune_entity)
    local rune_data = {}
    rune_data.origin = Utilities:Vector_to_array(rune_entity:GetOrigin())
    rune_data.type = "Rune"
    return rune_data
end

function World_data_builder:Insert_runes()
    local rune_entity = Entities:FindByClassname(nil, "dota_item_rune")
    while rune_entity ~= nil do
        if IsLocationVisible(self.requesting_hero:GetTeam(), rune_entity:GetOrigin()) then
            self.entities[rune_entity:entindex()] = self:Get_rune_data(rune_entity)
        end
        rune_entity = Entities:FindByClassname(rune_entity, "dota_item_rune")
    end
end

---@param flags table should_get_invulnerable: ```boolean```
---@return table all_units
function World_data_builder:Get_all_units(flags)
    local invulnerable_flag = 0

    if flags.should_get_invulnerable then
        invulnerable_flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    end

    return FindUnitsInRadius(
        self.requesting_hero:GetTeamNumber(),
        self.requesting_hero:GetOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE +
        invulnerable_flag + 
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        true
    )
end

function World_data_builder:Insert_all_towers()
    local all_units = FindUnitsInRadius(
        self.requesting_hero:GetTeamNumber(),
        self.requesting_hero:GetOrigin(),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        true
    )

    for _index, unit in ipairs(all_units) do
        if unit:IsTower() then
            self.entities[unit:entindex()] = self:Get_unit_data(unit)
        end
    end
end

function World_data_builder:Insert_all_units()
    self.all_units = self:Get_all_units( { should_get_invulnerable = false } )
    Utilities:Insert_range(self.all_units, self:Get_all_units( { should_get_invulnerable = true } ))

    for _index, unit in ipairs(self.all_units) do
        self.entities[unit:entindex()] = self:Get_unit_data(unit)
    end

    self:Insert_all_towers()
end

---@param hero_entity CDOTA_BaseNPC_Hero
---@return table entities
function World_data_builder:Get_all_entities(hero_entity)
    self.requesting_hero = hero_entity
    self.requesting_team = hero_entity:GetTeam()
    self.entities = {}
    self.all_units = {}

    self:Insert_trees()
    self:Insert_runes()
    self:Insert_all_units()

    return self.entities
end



return World_data_builder