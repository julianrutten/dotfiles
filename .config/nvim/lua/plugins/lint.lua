return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            php = { "phpstan" },
        }

        -- Configure PHPStan to use project config
        lint.linters.phpstan = {
            cmd = "vendor/bin/phpstan",
            stdin = false,
            args = { "analyse", "--error-format=json", "--no-progress" },
            stream = "stdout",
            ignore_exitcode = true,
            parser = function(output, bufnr)
                if output == "" then
                    return {}
                end

                local ok, decoded = pcall(vim.json.decode, output)
                if not ok then
                    return {}
                end

                local diagnostics = {}
                local filepath = vim.api.nvim_buf_get_name(bufnr)

                for _, file in pairs(decoded.files or {}) do
                    for _, message in ipairs(file.messages or {}) do
                        -- Only show errors for current buffer
                        if file.path and filepath:sub(-#file.path) == file.path then
                            table.insert(diagnostics, {
                                lnum = (message.line or 1) - 1,
                                col = 0,
                                end_lnum = (message.line or 1) - 1,
                                end_col = 0,
                                severity = vim.diagnostic.severity.ERROR,
                                message = message.message,
                                source = "phpstan",
                            })
                        end
                    end
                end

                return diagnostics
            end,
        }

        -- Auto-lint on save and when entering buffer
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
            group = lint_augroup,
            callback = function()
                -- Only lint if phpstan exists in project
                if vim.fn.filereadable("vendor/bin/phpstan") == 1 then
                    lint.try_lint()
                end
            end,
        })

        -- Manual lint command
        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })

        -- Run PHPStan on entire project and show in quickfix
        vim.keymap.set("n", "<leader>ps", function()
            vim.fn.setqflist({}, "r")
            vim.cmd("copen")
            vim.notify("Running PHPStan...", vim.log.levels.INFO)

            vim.fn.jobstart({ "vendor/bin/phpstan", "analyse", "--error-format=raw", "--no-progress" }, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                    if not data then return end

                    local qf_entries = {}
                    for _, line in ipairs(data) do
                        -- Format: /path/to/file.php:123:Error message
                        local file, lnum, msg = line:match("^(.+):(%d+):(.+)$")
                        if file and lnum and msg then
                            table.insert(qf_entries, {
                                filename = file,
                                lnum = tonumber(lnum),
                                text = msg,
                                type = "E",
                            })
                        end
                    end

                    if #qf_entries > 0 then
                        vim.fn.setqflist(qf_entries, "r")
                        vim.cmd("copen")
                        vim.notify("PHPStan: " .. #qf_entries .. " errors", vim.log.levels.WARN)
                    else
                        vim.notify("PHPStan: No errors found!", vim.log.levels.INFO)
                    end
                end,
                on_exit = function(_, code)
                    if code > 1 then
                        vim.notify("PHPStan failed to run", vim.log.levels.ERROR)
                    end
                end,
            })
        end, { desc = "PHPStan analyse project (Trouble)" })
    end,
}
