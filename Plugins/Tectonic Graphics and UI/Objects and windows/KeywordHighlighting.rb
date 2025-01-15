def battleKeywordsImportant
    return [
        "rainstorm",
        "sunshine",
        "sandstorm",
        "hail",
        "total eclipse",
        "eclipse",
        "full moon",
        "moonglow",
        "burning",
        "burned",
        "burns",
        "burn",
        "frostbiting",
        "frostbitten",
        "frostbites",
        "frostbite",
        "numbing",
        "numbed",
        "numbs",
        "numb",
        "poisoning",
        "poisoned",
        "poisons",
        "poison",
        "leeching",
        "leeched",
        "leeches",
        "leech",
        "dizzying",
        "dizzied",
        "dizzies",
        "dizzy",
        "waterlogging",
        "waterlogged",
        "waterlogs",
        "waterlog",
        "sleep",
        "asleep",
        "drowsy",
        "cursing",
        "cursed",
        "curse",
        "fracturing",
        "fractured",
        "fracture",
        "jinxing",
        "jinxed",
        "jinx",
        "maximize",
        "minimize",
        "aqua ring",
        "charged",
        "charge",
        "recoil",
        "flinch",
        "flinched",
        "flinching",
        "random added effects",
        "defensive stats",
        "offensive stats",
        "trapped",
        "traps",
        "trap",
    ]
end

def battleKeywordsImportantCaseSensitive
    return [
        "Sp. Atk",
        "Special Attack",
        "Attack",
        "Sp. Def",
        "Special Defense",
        "Defense",
        "Speed",
        "Accuracy",
        "Evasion",
    ]
end

def battleKeywordsUnimportant
    return [
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "ten",
        "eleven",
        "twelve",
        "thirteen",
        "fourteen",
        "fifteen",
        "sixteen",
        "seventeen",
        "eighteen",
        "nineteen",
        "twenty",
        "twice",
        "doubles",
        "double",
        "three times",
        "four times",
        "five times",
        "half",
        "one third",
        "two thirds",
        "one quarter",
        "three quarters",
        "one fifth",
        "1/6th",
        "1/8th",
        "1/10th",
        "1/12th",
        "1/16th",
    ]
end

def addBattleKeywordHighlighting(description)
    # Highlight very important words in red
    importantColorTag = getSkinColor(nil, 2, darkMode?, true)
    battleKeywordsImportant.each do |keyword|
        description = description.gsub(/\b(#{keyword})\b/i,"#{importantColorTag}\\1</c3>")
    end
    battleKeywordsImportantCaseSensitive.each do |keyword|
        description = description.gsub(/\b(#{keyword})\b/,"#{importantColorTag}\\1</c3>")
    end

    # Outline less important keywords
    unimportantColorTag = getSkinColor(nil, 13, darkMode?, true)
    battleKeywordsUnimportant.each do |keyword|
        description = description.gsub(/\b(#{keyword})\b/i,"#{unimportantColorTag}\\1</c3>")
    end
    description = description.gsub(/\b(\d+%)/i,"#{unimportantColorTag}\\1</c3>")

    return description
end