package com.service.service.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TesteController {

    @GetMapping("teste")
    public ResponseEntity<String> teste() {
        return ResponseEntity.ok("teste");
    }
}
