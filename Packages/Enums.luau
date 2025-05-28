--!strict

local enums = {
    States = {
        States = {
            Easy = 1,
            Mid = 2,
            Hard = 3,
        },
    },
}

function enums:Find(category: string, subfolder: string, index: number): string?
    if not enums[category] then
        return warn(`Cant find category in enums: {category}`)
    end

    if not enums[category][subfolder] then
        return warn(`Cant find subfolder in category {category}: {subfolder}`)
    end

    for name: string, i: number in enums[category][subfolder] do
        if i == index then
            return name
        end
    end

    return
end

table.freeze(enums)

export type Enums = typeof(enums)
return enums