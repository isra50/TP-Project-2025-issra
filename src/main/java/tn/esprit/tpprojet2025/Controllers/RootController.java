package tn.esprit.tpprojet2025.Controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class RootController {

    @GetMapping("/")
    public String home() {
        return "Welcome to the TP-Project-2025-issra application!";
    }

    @GetMapping("/actuator/health")
    public Map<String, String> health() {
        Map<String, String> healthMap = new HashMap<>();
        healthMap.put("status", "UP");
        return healthMap;
    }
}

