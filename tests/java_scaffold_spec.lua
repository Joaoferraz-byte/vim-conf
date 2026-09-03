vim.opt.rtp:append(vim.fn.getcwd())

local scaffold = require("java_scaffold")

local valid_packages = {
  "",
  "com.example",
  "com.example.spring_boot",
  "a.b2",
}
for _, package in ipairs(valid_packages) do
  assert(scaffold._valid_package(package), "expected valid package: " .. package)
end

local invalid_packages = {
  "Com.example",
  "com..example",
  "com.example-name",
  "1com.example",
  "../escape",
}
for _, package in ipairs(invalid_packages) do
  assert(not scaffold._valid_package(package), "expected invalid package: " .. package)
end

for _, class_name in ipairs({ "Main", "OrderService2", "Internal_" }) do
  assert(scaffold._valid_class_name(class_name), "expected valid class: " .. class_name)
end
for _, class_name in ipairs({ "main", "2Main", "Main-Class", "" }) do
  assert(not scaffold._valid_class_name(class_name), "expected invalid class: " .. class_name)
end

assert(scaffold._inferred_kind("PaymentException") == "exception")
assert(scaffold._inferred_kind("PaymentError") == "exception")
assert(scaffold._inferred_kind("PaymentService") == "class")
assert(scaffold._render("com.example", "Main", "class") == "package com.example;\n\npublic class Main {\n}\n")
assert(scaffold._render("com.example", "PaymentException", "exception") == "package com.example;\n\npublic class PaymentException extends RuntimeException {\n}\n")
assert(scaffold._render("com.example", "PaymentPort", "interface") == "package com.example;\n\npublic interface PaymentPort {\n}\n")
assert(scaffold._render("com.example", "PaymentState", "enum") == "package com.example;\n\npublic enum PaymentState {\n}\n")
assert(scaffold._render("com.example", "Payment", "record") == "package com.example;\n\npublic record Payment() {\n}\n")
assert(scaffold._render("", "Main", "class") == "public class Main {\n}\n")

local root = vim.fn.tempname()
local source = root .. "/src/main/java"
vim.fn.mkdir(source .. "/com/example", "p")
local target = source .. "/com/example/Main.java"
assert(scaffold._contains(root, target))
assert(not scaffold._contains(root, root .. "/../escape.java"))

local project = vim.fn.tempname()
vim.fn.mkdir(project, "p")
vim.fn.writefile({
  "<project>",
  "  <groupId>com.example</groupId>",
  "</project>",
}, project .. "/pom.xml")
assert(scaffold._project_package(project) == "com.example")
vim.fn.delete(root, "rf")
vim.fn.delete(project, "rf")

vim.cmd("qa!")
