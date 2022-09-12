const CONTAINERS = Dict(
    :BML => Dict(
        :name => "Bomblet",
        :type => 1,
        :stab => 10
    ),
    :SHL => Dict(
        :name => "Shell",
        :type => 1,
        :stab => 10
    ),
    :MNE => Dict(
        :name => "Mine",
        :type => 1,
        :stab => 10
    ),
    :SB_RKT => Dict(
        :name => "Surface Burst Rocket",
        :type => 1,
        :stab => 15
    ),
    :SB_MSL => Dict(
        :name => "Surface Burst Missile",
        :type => 1,
        :stab => 15
    ),
    :BOM => Dict(
        :name => "Bomb",
        :type => 2,
        :stab => 15
    ),
    :NKN => Dict(
        :name => "Unknown",
        :type => 2,
        :stab => 15
    ),
    :AB_RKT => Dict(
        :name => "Air Burst Rocket",
        :type => 2,
        :stab => 15
    ),
    :AB_MSL => Dict(
        :name => "Air Burst Missile",
        :type => 2,
        :stab => 15
    ),
    :SPR => Dict(
        :name => "Tank",
        :type => 3
    ),
    :GEN => Dict(
        :name => "Aerosols",
        :type => 3
    )
)


const PROCEDURES = Dict(
    :simplified => Dict(
        :name => "Simplified Procedure"
    ),
    :A => Dict(
        :name => "Non Persistent Agents"
    ),
    :B => Dict(
        :name => "Persistent Agents"
    ),
    :C => Dict(
        :name => "Unobserved Release"
    ),
    :P => Dict(
        :name => "Localized Point Release"
    ),
    :Q => Dict(
        :name => "Large Area Release"
    ),
    :R => Dict(
        :name => "Unknown Container"
    )
)


const INCIDENTS = Dict(
    :chem => Dict(
        :name => "Chemical"
    ),
    :bio => Dict(
        :name => "Biological"
    ),
    :radio => Dict(
        :name => "Radiological"
    ),
    :nucl => Dict(
        :name => "Nuclear"
    )
)
