return {
    {
        "EdenEast/nightfox.nvim",
        -- config = function()
        --     vim.cmd.colorscheme('nightfox')
        -- end,
    },
    {
        "sainnhe/edge",
        -- config = function()
        --     vim.cmd.colorscheme('edge')
        -- end,
    },
    {
        "folke/tokyonight.nvim",
        opts = {
            style = "night",
            dim_inactive = true,

            on_colors = function(colors)
                colors.border = "#009688"
                --colors.fg = "#FFFFFF"
                --colors.bg = "#192330"
                colors.keyword = "#66D9EF"
                colors.operator = "#F9276C"
                colors.type = "#FA6543"
                colors.function_call = "#A6E22E"
                colors.function_decl = "#FFC66D"
                colors.annotation = "#BBB529"
                colors.parameter = "#FF992F"
                colors.string = "#9d79d6"
                colors.comment = "#629755"
                colors.number = "#F3CC64"
            end,

            on_highlights = function(hl, c)
                hl["Keyword"] = { fg = c.keyword }
                hl["@keyword"] = { fg = c.keyword, bold = true }
                hl["@keyword.function"] = { fg = c.keyword, bold = true }
                --hl["@keyword.modifier"] = { fg = c.keyword, bold = true }
                hl["@keyword.conditional"] = { fg = c.keyword, bold = true, italic = true }
                hl["@keyword.repeat"] = { fg = c.keyword, bold = true, italic = true }
                --hl["@keyword.import"] = { fg = c.keyword }
                --hl["@keyword.storage"] = { fg = c.keyword, bold = true }            
                hl["@keyword.exception"] = { fg = c.keyword, bold = true } 
                hl["@keyword.return"] = { fg = c.keyword, bold = true, italic = true }
                --hl["@keyword.operator"] = { fg = c.operator, bold = true } 
                

                hl["Function"] = { fg = c.function_decl }
                hl["@function.call"] = { fg = c.function_call }
                hl["@function.method.call"] = { fg = c.function_call }
                hl["@function.builtin"] = { fg = c.function_call }
                hl["@constructor"] = { fg = c.function_decl }               

                hl["Type"] = { fg = c.type }
                hl["@type.builtin"] = { fg = c.type }
                hl["@type.qualifier"] = { fg = c.keyword }


                hl["@operator"] = { fg = c.operator }
                hl["@annotation"] = { fg = c.annotation }
                hl["@attribute"] = { fg = c.annotation }
                hl["@variable"] = { fg = "#FFFFFF" }
                hl["@variable.parameter"] = { fg = c.parameter, italic = true }
                hl["@lsp.type.parameter"] = { fg = c.parameter, italic = true }
                hl["@variable.builtin"] = { fg = c.keyword, bold = true }
                hl["@variable.member"] = { fg = c.parameter }

                hl["@punctuation"] = { fg = c.operator } 
                hl["String"] = { fg = c.string }
                hl["Comment"] = { fg = c.comment }
                hl["NUmber"] = { fg = c.number }

            end,
    

        },
    }
  }