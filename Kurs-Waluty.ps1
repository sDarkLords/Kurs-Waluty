<#
  .SYNOPSIS
  Wyświetla kurs wymiany z ostatnich 5 dni

  .DESCRIPTION
  Skrypt pobiera dane z ostatnich 5 dni dotyczące kursu podanej waluty z API NBP i oblicza rożnicę między każdym dniem

  .PARAMETER kodwaluty
  Parametr określa kod waluty podany przez użytkownika 

  .PARAMETER dzienkoncowy
  Parametr określa ostatni dzień, do ktorego należy zbierać dane walutowe
  
  .EXAMPLE
  Podaj kod waluty (np. USD, EUR): EUR
  Kursy waluty EUR z ostatnich 5 dni:
  2025-05-07 : 4.2757 PLN
  2025-05-08 : 4.2714 PLN
  Roznica wzgledem poprzedniego dnia: -0.0043
  2025-05-09 : 4.2414 PLN
  Roznica wzgledem poprzedniego dnia: -0.0300
  2025-05-12 : 4.2337 PLN
  Roznica wzgledem poprzedniego dnia: -0.0077
  2025-05-13 : 4.2525 PLN
  Roznica wzgledem poprzedniego dnia: 0.0188
#>

#Pobranie kodu waluty użytkownika
$kodwaluty = Read-Host "Podaj kod waluty (np. USD, EUR)" 

#Skonfiguruj dzisiejszą datę
$dzienkoncowy = Get-Date -Format "yyyy-MM-dd"
#Skonfiguruj datę początkową (odejmij 10 dni od dzisiejszej daty, aby upewnić się, że jest 5 dni roboczych) 
$datarozpoczecia = (Get-Date).AddDays(-10).ToString("yyyy-MM-dd") 

#Pobierz dane z API NBP
$url = "http://api.nbp.pl/api/exchangerates/rates/A/$kodwaluty/$datarozpoczecia/$dzienkoncowy/?format=json"

try {
    $odpowiedz = Invoke-RestMethod -Uri $url -Method Get

    #Posortuj dane według daty i wybierz ostatnie 5 dni
    $kursy = $odpowiedz.rates | Sort-Object -Property effectiveDate | Select-Object -Last 5

    #Podajemy kodwaluty wymiany z ostatnich 5 dni
    Write-Host "Kursy waluty $kodwaluty z ostatnich 5 dni:"
    $poprzednikurs = $null

    foreach ($kurs in $kursy) {
        $data = $kurs.effectiveDate
        $wartosc = $kurs.mid
        Write-Host "$data : $wartosc PLN"

        if ($poprzednikurs -ne $null){
            $difference = [math]::Round($wartosc - $poprzednikurs, 4)
            Write-Host "  Roznica wzgledem poprzedniego dnia: $difference"
        }
        $poprzednikurs = $wartosc
    }
}
#Wyświetlanie wiadomości o błęndach , jeśli coś pojdzie nie tak
catch {
    Write-Host "Wystapil blad podczas pobierania danych. Upewnij się, ze kod waluty jest poprawny."
}