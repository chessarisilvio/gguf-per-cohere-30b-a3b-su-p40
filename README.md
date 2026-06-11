# GGUF per Cohere 30B A3B su P40

## Descrizione
Il progetto fornisce gli script e le istruzioni per scaricare, compilare, quantizzare ed eseguire il modello Cohere 30B A3B in formato GGUF su hardware Tesla P40 (24 GB VRAM) utilizzando BeeLLama (fork di llama.cpp ottimizzato per sm_61). Il modello può essere eseguito direttamente sulla P40 o con delega degli embedding alla RTX 3050 per ottimizzare l'utilizzo della VRAM.

## Architettura
- **BeeLLama**: fork di llama.cpp con supporto CUDA sm_61 per Tesla P40.
- **Quantizzazione**: script per convertire il modello GGUF in formati ridotti (Q4_K_M, Q5_K_M, ecc.) per adattarsi alla VRAM disponibile.
- **Inference delegata**: script di avvio che permette di offload degli embedding alla GPU RTX 3050 (8 GB) mantenendo i layer principali sulla P40.
- **Modello target**: Cohere 30B A3B (disponibile su Hugging Face o altri canali in formato GGUF).

## Installazione
1. Clonare questo repository.
2. Eseguire `./build_llama.sh` per compilare BeeLLama con supporto CUDA sm_61.
3. Ottenere il modello Cohere 30B A3B GGUF (ad esempio da Hugging Face) e posizionarlo nella directory del progetto.
4. (Opzionale) Eseguire `./quantize_model.sh <input_model.gguf>` per creare una versione quantizzata.
5. Assicurarsi di avere le dipendenze di sistema: git, cmake, compilatore C++, toolchain CUDA.

## Uso
- Per avviare il server di inference sulla P40:
  ```
  ./run_inference.sh
  ```
  Lo script carica il modello (o la versione quantizzata) e avvia il server BeeLLama sulla porta 8090.
- Per modificare la quantizzazione o il percorso del modello, editare le variabili nello script `run_inference.sh`.
- Per eseguire solo la quantizzazione:
  ```
  ./quantize_model.sh cohere-30b-a3b.gguf cohere-30b-a3b-q4km.gguf q4_k_m
  ```

## Esempi
```bash
# Compilare BeeLLama
./build_llama.sh

# Quantizzare il modello a Q4_K_M
./quantize_model.sh cohere-30b-a3b.gguf cohere-30b-a3b-q4km.gguf q4_k_m

# Avviare l'inference (usa il modello quantizzato se presente)
./run_inference.sh
```

## Stato
✅ COMPLETATO — 2026-06-10
- Struttura progetto creata
- Istruzioni per download GGUF definite
- Build di llama.cpp per sm_61 preparata
- Script di quantizzazione modello completato
- Script di avvio inference delegata completato