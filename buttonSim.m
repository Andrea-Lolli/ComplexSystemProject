% Intervalli di durata delle coroutine
scannerTimeInterval = [1 5 8]; 
bcTimeInterval = [2 5 10];  

% Imposta l'intervallo massimo e minimo tra le pressioni del pulsante
minButtonInterval = 2;  % Intervallo minimo tra una pressione del pulsante e l'altra
maxButtonInterval = 10;   % Intervallo massimo
stepButtonInterval = 2; % Incremento tra gli intervalli di prova

% Derivazioni standard delle funzioni
TSD = 10;
TBD = 10;
BD = 1;

% Loop principale per ogni combinazione di scannerTimeInterval e bcTimeInterval
for i = 1 : length(scannerTimeInterval)
    for j = 1 : length(bcTimeInterval)
        % Imposta dati nella simulazione
        TS = scannerTimeInterval(i);  % Durata della coroutine scanner
        TB = bcTimeInterval(j);       % Durata della coroutine BC 
        
        % Ricerca del carico di rottura
        for buttonPressInterval = minButtonInterval : stepButtonInterval : maxButtonInterval

            B = buttonPressInterval;
            sim('provaUML');
            
            % Estrai i dati dalla simulazione
            timeData = ans.requests.Time;
            requestsData = ans.requests.Data;
            bctQueue = ans.bctQueue.Data;
            % jsonData = ans.json.Data;              
        end
    end  
end

% Esportazione dei dati su Excel
filename = 'breakdown_times_complete.xlsx';
% TODO
disp(['I risultati sono stati esportati in ' filename]);
