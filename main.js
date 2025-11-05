require('@g-js-api/g.js');
const fs = require('fs');

$.exportConfig({
  type: 'savefile',
  options: { info: true }
}).then(x => { 

    const instructions = JSON.parse(fs.readFileSync("code.json", "utf8"));
    const systeminfo = JSON.parse(fs.readFileSync("systeminfo.json", "utf8"));
    const firstinstrgroup = 300;
    const mainloopgroup = 202;
    const n = instructions.length;
    if (n >= 9900) {
        // error code trop long
    }
    else{
        const keybinds = systeminfo["keybinds"];
        for (let i = 0; i < keybinds.length; i++){
            $.add(object({
                OBJ_ID: 1268,
                X: 465,
                Y: 1095,
                TARGET: group(77 + 3 * keybinds[i]),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(200),
            }))
        }
        $.add(object({
            OBJ_ID: 1811,
            X: 645,
            Y: 1095,
            COUNT: systeminfo["ticks_per_frame"],
            TARGET: group(203),
            ITEM: 9980,
            ACTIVATE_GROUP: true,
            SPAWN_TRIGGERED: true,
            MULTI_TRIGGER: true,
            GROUPS: group(201),
        }))
        const palette = systeminfo["palette"];
        for (let i = 0; i < palette.length; i++){
            $.add(object({
                OBJ_ID: 1811,
                X: 705,
                Y: 1095 + 30 * i,
                COUNT: i,
                TARGET: group(205 + i),
                ITEM: 4001,
                ACTIVATE_GROUP: true,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(204),
            }))
            $.add(object({
                OBJ_ID: 1006,
                X: 735,
                Y: 1095 + 30 * i,
                TRIGGER_RED: palette[i][0],
                TRIGGER_GREEN: palette[i][1],
                TRIGGER_BLUE: palette[i][2],
                HOLD: 0.01 * (systeminfo["ticks_par_frame"] + 1),
                TARGET_TYPE: true,
                TARGET: group(4001),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(205 + i),
            }))
        }
        for (let i = 0; i < n; i++){
            let p = instructions[i].length - 1;
            $.add(object({
                OBJ_ID: 1811,
                X: 2445 + 30 * i,
                Y: 135,
                COUNT: i + 1,
                TARGET: group(firstinstrgroup + i),
                ITEM: 9982,
                ACTIVATE_GROUP: true,
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: group(mainloopgroup),
            }))
            for (let j = 0; j < p; j++){
                let inst = instructions[i][j];
                if (inst[0] == 100){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 2445 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        COUNT: inst[2],
                        ITEM: inst[1],
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        OVERRIDE_COUNT: true,
                        GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
                    }))
                }
                else if (inst[0] == 101){
                    $.add(object({
                        OBJ_ID: 3619,
                        X: 2445 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        ITEM_ID_1: inst[2],
                        TYPE_1: 1,
                        ITEM_TARGET: inst[1],
                        ITEM_TARGET_TYPE: 1,
                        MOD: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
                    }))
                }
                else if (inst[0] == 102){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 2445 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        COUNT: inst[2],
                        ITEM: inst[1],
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
                    }))
                }
                else if (inst[0] == 103){
                    $.add(object({
                        OBJ_ID: 3619,
                        X: 2445 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        ITEM_ID_1: inst[2],
                        TYPE_1: 1,
                        ITEM_TARGET: inst[1],
                        ITEM_TARGET_TYPE: 1,
                        ASSIGN_OP: 1,
                        MOD: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
                    }))
                }
                else if (inst[0] == 104){
                    $.add(object({
                        OBJ_ID: 1817,
                        X: 2445 + 2 * j + 30 * i,
                        Y: 105 - 30 * j,
                        MODIFIER: inst[2],
                        ITEM: inst[1],
                        MULT_DIV: 1,
                        SPAWN_TRIGGERED: true,
                        MULTI_TRIGGER: true,
                        GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
                    }))
                }
            }
            $.add(object({
                OBJ_ID: 1268,
                X: 2445 + 2 * p + 30 * i,
                Y: 105 - 30 * p,
                TARGET: group(instructions[i][p][0]),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: [group(firstinstrgroup + i), group(firstinstrgroup + n)],
            }))
            $.add(object({
                OBJ_ID: 1049,
                X: 2445 + 2 * (p + 1) + 30 * i,
                Y: 105 - 30 * (p + 1),
                TARGET: group(200 + n),
                SPAWN_TRIGGERED: true,
                MULTI_TRIGGER: true,
                GROUPS: [group(firstinstrgroup + i)],
            }))
        }
        $.add(object({
            OBJ_ID: 1049,
            X: 2445 + 2 * (p + 1) + 30 * i,
            Y: 105 - 30 * (p + 1),
            TARGET: group(firstinstrgroup + n),
            ACTIVATE_GROUP: true,
            SPAWN_TRIGGERED: true,
            MULTI_TRIGGER: true,
            GROUPS: [group(firstinstrgroup + i)],
        }))
        // for (let i = 0; i < 20; i++){
        //     for (let j = 0; j < 20; j++){
        //           $.add(object({
        //             OBJ_ID: 1615,
        //             X: 1605 + 90 * j,
        //             Y: 825 - 30 * i, 
        //             ITEM: 9600 + 20 * i + j,
        //         }))
        //     }
        // }
    }
});
