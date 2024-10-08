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

    @GetMapping("hello-world")
    public ResponseEntity<String> helloWorld() {
        return ResponseEntity.ok("hello-world");
    }

    @GetMapping("hello-world-2")
    public ResponseEntity<String> helloWorld2() {
        return ResponseEntity.ok("hello-world-2");
    }

    @GetMapping("hello-world-3")
    public ResponseEntity<String> helloWorld3() {
        return ResponseEntity.ok("hello-world-3");
    }
}
