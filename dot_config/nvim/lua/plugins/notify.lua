return {
    {
        "rcarriga/nvim-notify",
        opts = function(_, opts)
          table.insert(opts, 1, {
            timeout = 15000,
          })
        end,
    }
}
