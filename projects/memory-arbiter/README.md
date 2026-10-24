<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

<div align="center">
  <h1>Multi-Client Banked Memory Fabric & Response Reorder</h1>
  <p><strong>Bank-Conflict Arbitration, Reserved Response Slots & Per-Client In-Order Retirement</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.md">Vulcan Showcase Index</a> ·
    <a href="rtl/">RTL Source</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

## Executive Summary

A multi-client, multi-bank memory interconnect fabric that arbitrates concurrent read/write requests across independent SRAM banks while reserving response slots to guarantee deadlock-free, in-order per-client transaction retirement.

| Dimension | Verified Deliverable |
| :--- | :--- |
| **RTL Modules (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv), [`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv), [`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv), [`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv), [`rtl/mf_completion.sv`](rtl/mf_completion.sv), [`rtl/mf_csr.sv`](rtl/mf_csr.sv), [`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv), [`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **Verification Summary** | 27 seeded runs · 6,624 measured memory transactions · 0 ordering or data hazards |
| **License** | [MIT License](../../LICENSE) |

A synthesizable SystemVerilog subsystem that shares one or two external memory
banks among independent clients while preserving each client's response order.

**Highlights:** round-robin bank arbitration, queued requests, reserved completion
slots, stable stalled requests, cross-bank completion reordering, byte-strobed
writes, explicit errors, configuration/status registers and interrupts.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `CLIENTS` | 3 | 1-8 |
| `BANKS` | 2 | 1 or 2 |
| `SLOTS` | 2 per client | 1-8 |

Requests carry an opaque eight-bit tag, a 16-bit byte address, 32-bit data and
four write strobes. Tags may repeat. For two banks, address bit 2 selects the
bank; unaligned requests instead receive an ordered local error.

## Results

The accepted implementation contains **eight RTL modules** and **624 nonblank,
non-comment RTL lines**. Its independent public-interface regression passed
**27 configuration/seed runs**: eight parameter combinations and an independently
compiled default, each with seeds 17, 41 and 97. The measured post-reset epochs
completed **96 transactions per client**, half reads and half writes, for
**6,624 transactions**. The mandatory runs covered **60,651 simulation cycles**,
including additional directed traffic. Eight endpoint smoke runs also passed.

Checks covered repeated tags, exact byte-write readback, full-slot backpressure,
concurrent banks, actual out-of-order bank completion with ordered client
retirement, errors, reset epochs, CSR snapshots, interrupts and error-dominant
W1C. Fairness was checked as a bound on available-bank grants, not an
unconditional latency promise. A disposable response-tag corruption was detected
as a transaction mismatch with a nonzero checker exit.

Default-top Yosys generic synthesis completed with **6,075 generic cells**, zero
structural-check problems and no remaining inferred latches. Six unique
memory-to-register lowering warnings were retained. These are scoped simulation
and generic-synthesis results, not exhaustive formal proof, technology-mapped
area, timing closure, power estimates, board tests or silicon measurements.
The tested matrix is a subset of the supported parameter ranges.

## Integrate

Instantiate [`memory_fabric`](rtl/memory_fabric.sv) with all eight files in
[`rtl/`](rtl/), using one clock and synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `c_req_*`, `c_rsp_*` | Packed per-client request and ordered response channels |
| `b_req_*`, `b_rsp_*` | Independent external bank request and response channels |
| `csr_req_*`, `csr_rsp_*` | Custom 32-bit configuration/status interface |
| `irq` | Masked sticky error indication |

Producers hold valid and payload until handshake. Each bank accepts at most one
request awaiting response, and its responder must return exactly one response,
no earlier than the following clock edge. Completion storage is reserved at
client admission, so client backpressure does not block a contracted bank
response. Requests may experience documented per-client head-of-line blocking.
There is no fabricated timeout completion.

Reset flushes all outstanding transaction state and must also flush the external
responder; already committed external memory writes may remain. Writes and error
responses return zero data. The CSR interface is **not AXI or APB** and permits
one pending response. Invalid accesses return explicit errors.

Compile from this directory:

```bash
iverilog -g2012 -s memory_fabric -t null rtl/*.sv
```

This checks compilation only; it does not rerun the reported regression.

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>

---
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
