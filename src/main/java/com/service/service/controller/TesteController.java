package com.service.service.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TesteController {


    @GetMapping("my-hello-world")
    public ResponseEntity<String> helloWorld() {
        return ResponseEntity.ok("my-hello-world");
    }
}
