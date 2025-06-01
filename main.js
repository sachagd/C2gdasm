require('@g-js-api/g.js');
const fs = require('fs');

$.exportConfig({
  type: 'savefile',
  options: { info: true }
}).then(x => { 

    const sinstructions = fs.readFileSync("code.json", "utf8");
    const instructions = JSON.parse(sinstructions);

    if (instructions.length >= 9900) {
        // error code trop long
    }
    else{
        for (let i = 0; i < instructions.length; i++){
            let n = instructions[i].length - 1;
            $.add(object({
                OBJ_ID: 1811,
                X: 1635 + 30 * i,
                Y: 135,
                COUNT: i + 1,
                TARGET: group(200 + i),
                ITEM: 9983,
                ACTIVATE_GROUP: true,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(112),
            }))
            for (let j = 0; j < n; j++){
                let inst = instructions[i][j];
                if (inst[0] == 100){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 1635 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        COUNT: inst[2],
                        ITEM: inst[1],
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        OVERRIDE_COUNT: true,
                        GROUPS: [group(200 + i), group(236)],
                    }))
                }
                else if (inst[0] == 101){
                    $.add(object({
                        OBJ_ID: 3619,
                        X: 1635 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        ITEM_ID_1: inst[2],
                        TYPE_1: 1,
                        ITEM_TARGET: inst[1],
                        ITEM_TARGET_TYPE: 1,
                        MOD: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(200 + i), group(236)],
                    }))
                }
                else if (inst[0] == 102){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 1635 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        COUNT: inst[2],
                        ITEM: inst[1],
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(200 + i), group(236)],
                    }))
                }
                else if (inst[0] == 103){
                    $.add(object({
                        OBJ_ID: 3619,
                        X: 1635 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        ITEM_ID_1: inst[2],
                        TYPE_1: 1,
                        ITEM_TARGET: inst[1],
                        ITEM_TARGET_TYPE: 1,
                        ASSIGN_OP: 1,
                        MOD: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(200 + i), group(236)],
                    }))
                }
                else if (inst[0] == 104){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 1635 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        MODIFIER: inst[2],
                        ITEM: inst[1],
                        MULT_DIV: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(200 + i), group(236)],
                    }))
                }
            }
            $.add(object({
                OBJ_ID: 1268,
                X: 1635 + 2 * n + 30 * i,
                Y: 105 - 30 * n,
                TARGET: group(instructions[i][n][0]),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: [group(200 + i), group(236)],
            }))
        }
        for (let i = 0; i < 20; i++){
            for (let j = 0; j < 20; j++){
                  $.add(object({
                    OBJ_ID: 1615,
                    X: 1605 + 90 * j,
                    Y: 825 - 30 * i, 
                    ITEM: 9600 + 20 * i + j,
                }))
            }
        }
    }
});
