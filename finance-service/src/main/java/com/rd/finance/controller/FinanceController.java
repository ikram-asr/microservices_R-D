package com.rd.finance.controller;

import com.rd.finance.dto.BudgetRequest;
import com.rd.finance.dto.BudgetResponse;
import com.rd.finance.dto.ExpenseRequest;
import com.rd.finance.model.Expense;
import com.rd.finance.service.FinanceService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/finance")
public class FinanceController {

    @Autowired
    private FinanceService financeService;

    @GetMapping("/budgets")
    public ResponseEntity<List<BudgetResponse>> getAllBudgets() {
        return ResponseEntity.ok(financeService.getAllBudgets());
    }

    @GetMapping("/budgets/project/{projectId}")
    public ResponseEntity<List<BudgetResponse>> getBudgetsByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(financeService.getBudgetsByProject(projectId));
    }

    @GetMapping("/budgets/{id}")
    public ResponseEntity<BudgetResponse> getBudgetById(@PathVariable Long id) {
        try {
            BudgetResponse budget = financeService.getBudgetById(id);
            return ResponseEntity.ok(budget);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/budgets")
    public ResponseEntity<BudgetResponse> createBudget(@Valid @RequestBody BudgetRequest request) {
        try {
            BudgetResponse budget = financeService.createBudget(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(budget);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PostMapping("/expenses")
    public ResponseEntity<Expense> createExpense(
            @Valid @RequestBody ExpenseRequest request,
            @RequestHeader("X-User-Id") String userIdHeader) {
        try {
            Long userId = Long.parseLong(userIdHeader);
            Expense expense = financeService.createExpense(request, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(expense);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @GetMapping("/expenses/project/{projectId}")
    public ResponseEntity<List<Expense>> getExpensesByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(financeService.getExpensesByProject(projectId));
    }
}

