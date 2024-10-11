package com.service.service.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TesteController {

    @GetMapping("teste2")
    public ResponseEntity<String> teste2() {
        return ResponseEntity.ok("teste2");
    }
}
