% Intervalli di durata delle coroutine
scannerTimeInterval = [1 5]; 
bcTimeInterval = [2 7];  

% Imposta l'intervallo massimo e minimo tra le pressioni del pulsante
minButtonInterval = 2;  % Intervallo minimo tra una pressione del pulsante e l'altra
maxButtonInterval = 10;   % Intervallo massimo
stepButtonInterval = 2; % Incremento tra gli intervalli di prova

% Prepara una struttura dati per raccogliere i risultati
results = {};
row = 1;  % Indicatore della riga in cui iniziare a scrivere nel file Excel

% Prepara una matrice per il secondo foglio
summaryResults = {};
summaryRow = 1;

% Intestazione del secondo foglio
summaryHeader = {'B'};
for i = 1:length(scannerTimeInterval)
    for j = 1:length(bcTimeInterval)
        summaryHeader{end+1} = ['TS = ', num2str(scannerTimeInterval(i)), ', TB = ', num2str(bcTimeInterval(j)), ' (Requests)'];
        summaryHeader{end+1} = ['TS = ', num2str(scannerTimeInterval(i)), ', TB = ', num2str(bcTimeInterval(j)), ' (BTCqueue)'];
    end
end
summaryResults(summaryRow, 1:length(summaryHeader)) = summaryHeader;
summaryRow = summaryRow + 1;

% Loop principale per ogni combinazione di scannerTimeInterval e bcTimeInterval
for buttonPressInterval = minButtonInterval : stepButtonInterval : maxButtonInterval
    B = buttonPressInterval;

    % Inizia la riga di intestazione per B
    results{row, 1} = ['Input interval = ', num2str(B)];
    row = row + 1;

    % Prepara l'intestazione con Time, TS, TB
    headerRow = {'Time'};
    
    for i = 1 : length(scannerTimeInterval)
        for j = 1 : length(bcTimeInterval)
            TS = scannerTimeInterval(i);  % Durata della coroutine scanner
            TB = bcTimeInterval(j);       % Durata della coroutine BC 

            % Intestazione con TS e TB
            headerRow{end+1} = ['TS = ', num2str(TS), ', TB = ', num2str(TB)];
            headerRow{end+1} = '';  % Celle vuote per separare requests e bctQueue
        end
    end

    % Aggiungi l'intestazione al foglio di risultati
    results(row, 1:length(headerRow)) = headerRow;
    row = row + 1;

    % Trova la lunghezza massima dei dati tra tutte le simulazioni
    maxLength = 0;
    
    % Collezione dati per ciascuna combinazione di TS e TB
    dataMatrix = cell(maxLength, 1 + 2 * length(scannerTimeInterval) * length(bcTimeInterval));
    maxRequests = zeros(1, length(scannerTimeInterval) * length(bcTimeInterval));
    maxBctQueue = zeros(1, length(scannerTimeInterval) * length(bcTimeInterval));

    for i = 1 : length(scannerTimeInterval)
        for j = 1 : length(bcTimeInterval)
            TS = scannerTimeInterval(i);  
            TB = bcTimeInterval(j); 

            % Esegui la simulazione per questa terna di parametri
            sim('provaUML');
            
            % Estrai i dati dalla simulazione
            timeData = ans.requests.Time;
            requestsData = ans.requests.Data;
            bctQueueData = ans.bctQueue.Data;

            % Memorizza i dati raccolti in dataMatrix
            for tIdx = 1:length(timeData)
                dataMatrix{tIdx, 1} = timeData(tIdx);  % Salva il dato temporale solo una volta

                % Scrivi i dati delle richieste e della coda BC nelle colonne corrispondenti
                dataMatrix{tIdx, 2 * (i-1) * length(bcTimeInterval) + 2*j} = requestsData(tIdx);
                dataMatrix{tIdx, 2 * (i-1) * length(bcTimeInterval) + 2*j + 1} = bctQueueData(tIdx);
            end

            % Trova i valori massimi alla fine della simulazione
            maxRequests((i-1)*length(bcTimeInterval) + j) = requestsData(end);  % Ultimo valore
            maxBctQueue((i-1)*length(bcTimeInterval) + j) = bctQueueData(end);  % Ultimo valore

            % Aggiorna la lunghezza massima
            maxLength = max(maxLength, length(timeData));
        end
    end

    % Scrivi i dati nella matrice results
    for tIdx = 1:maxLength
        results(row, 1:size(dataMatrix, 2)) = dataMatrix(tIdx, :);
        row = row + 1;
    end

    % Aggiungi i risultati riassuntivi al secondo foglio
    summaryResults{summaryRow, 1} = B;
    colIdx = 2;
    for i = 1:length(scannerTimeInterval)
        for j = 1:length(bcTimeInterval)
            summaryResults{summaryRow, colIdx} = maxRequests((i-1)*length(bcTimeInterval) + j);
            summaryResults{summaryRow, colIdx+1} = maxBctQueue((i-1)*length(bcTimeInterval) + j);
            colIdx = colIdx + 2;
        end
    end
    summaryRow = summaryRow + 1;
end

% Esportazione dei dati su Excel
filename = 'breakdown_times_complete.xlsx';
xlswrite(filename, results);  % Primo foglio
xlswrite(filename, summaryResults, 'Summary');  % Secondo foglio chiamato "Summary"

disp(['I risultati sono stati esportati in ' filename]);