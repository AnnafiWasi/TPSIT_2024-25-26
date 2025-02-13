/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package jswing;
/**
 *
 * @author PC
 */
public class Stato {

    private double primoNumero = 0;
    private String operazione = "";

    public String gestisciInput(String input, String numeroAttuale) {
        try {
            switch (input) {
                case "C":
                    this.primoNumero = 0;
                    this.operazione = "";
                    return "";
                case "=":
                    return calcolaRisultato(numeroAttuale);
                case "+":
                case "-":
                case "*":
                case "/":
                case "n^x":
                case "x√n":
                case "%":
                    this.operazione = input;
                    this.primoNumero = Double.parseDouble(numeroAttuale);
                    return "";
                default:
                    return numeroAttuale + input;
            }
        } catch (NumberFormatException e) {
            return "Errore";
        }
    }

    private String calcolaRisultato(String secondoNumeroTesto) {
        try {
            double secondoNumero = Double.parseDouble(secondoNumeroTesto);
            double risultato = 0;
            switch (this.operazione) {
                case "+":
                    risultato = this.primoNumero + secondoNumero;
                    break;
                case "-":
                    risultato = this.primoNumero - secondoNumero;
                    break;
                case "*":
                    risultato = this.primoNumero * secondoNumero;
                    break;
                case "/":
                    if (secondoNumero != 0) {
                        risultato = this.primoNumero / secondoNumero;
                    } else {
                        return "Errore: /0";
                    }
                    break;
                case "n^x":
                    risultato = Math.pow(this.primoNumero, secondoNumero);
                    break;
                case "x√n":
                    risultato = Math.pow(this.primoNumero, 1.0 / secondoNumero);
                    break;
                case "%":
                    risultato = (this.primoNumero / 100) * secondoNumero;
                    break;
                default:
                    return"";
            }
            this.operazione = "";
            return String.valueOf(risultato);
        } catch (NumberFormatException e) {
            return "Errore";
        }
    }
}
