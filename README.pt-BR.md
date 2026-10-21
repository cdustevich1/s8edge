[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md) [![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README.pt-BR.md)

<div align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/icon%403x.png" width="80" alt="S8Edge Icon">
  <h1>S8Edge</h1>
</div>

Um tweak de jailbreak simples e leve que trouxe a popular estética de tela com bordas curvas para iPhones. No seu auge, este foi o meu tweak mais baixado, respondendo a uma tendência de design popular na comunidade.

---

<p align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/1.jpg" width="200" alt="Captura de Tela 1 do S8Edge">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/2.jpg" width="200" alt="Captura de Tela 2 do S8Edge">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/3.jpg" width="200" alt="Captura de Tela 3 do S8Edge">
</p>

---

## 💡 O Conceito

Este projeto não se tratava de adicionar funcionalidades complexas. Foi uma resposta direta a um pedido do subreddit `/r/jailbreak`. Em uma época em que celulares como o Samsung Galaxy S8 popularizavam telas com bordas curvas, um usuário queria uma maneira simples de trazer essa estética para o seu iPhone.

O S8Edge foi criado como uma solução simples, elegante e puramente cosmética para simular essa aparência.

## ✨ Funcionalidades

* **Bordas Curvas Simuladas:** O tweak adiciona uma sobreposição limpa à tela que dá a ilusão de bordas de tela curvas.
* **Cantos Arredondados:** Uma parte fundamental do efeito era arredondar os cantos da tela, que se tornou o aspecto mais popular do tweak.
* **Opções de Cores (Preto e Branco):** Os usuários podiam escolher entre uma sobreposição preta ou branca para combinar perfeitamente com a cor da borda de seus dispositivos.
* **Leve e Eficiente:** Projetado como uma sobreposição simples e passiva, o tweak teve impacto virtualmente zero no desempenho ou na vida útil da bateria.

## 🛠️ Implementação Técnica e a Correção para o iOS 16

### 1. O Problema Central no iOS 16
Antes do iOS 16, um tweak do SpringBoard podia criar uma `UIWindow` personalizada em qualquer lugar usando `[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]`. O UIKit renderizava automaticamente qualquer janela avulsa na tela principal.

A partir do **iOS 16**, a Apple reestruturou profundamente o gerenciamento de janelas e múltiplas telas no SpringBoard (principalmente para suportar o Stage Manager e monitores externos):
* As janelas do SpringBoard não são mais renderizadas globalmente baseadas na tela; em vez disso, as janelas precisam estar explicitamente associadas a uma **`UIWindowScene`** ativa (especificamente a `SBWindowScene` principal do SpringBoard).
* Se uma `UIWindow` é instanciada sem uma cena (ou pelo método legado `initWithFrame:`), o UIKit a coloca em uma cena virtual desconectada. A janela informa `hidden = NO` e limites válidos, mas o compositor de janelas **nunca a desenha na tela**.
* Além disso, a `SBWindowScene` nem sempre está conectada quando `-[SpringBoard applicationDidFinishLaunching:]` roda. Criar a janela prematuramente resultava em uma cena nula (`nil`).

### 2. Como o S8Edge Foi Corrigido
Para restaurar a funcionalidade completa no iOS 16+:
* **Detecção e Associação com a Cena:** O tweak inspeciona `[UIApplication sharedApplication].connectedScenes` em busca de uma `UIWindowScene` associada a `[UIScreen mainScreen]`, priorizando a `SBWindowScene` do SpringBoard. A janela de sobreposição agora é inicializada explicitamente com `-[CustoWindow initWithWindowScene:]`.
* **Monitoramento Dinâmico de Conexão:** Caso a `SBWindowScene` principal ainda não tenha se conectado na inicialização do SpringBoard, a classe `s8EdgeUI` escuta as notificações `UISceneWillConnectNotification` e `UISceneDidActivateNotification`, adiando a criação da janela até que a cena esteja pronta. Também lida com `UISceneDidDisconnectNotification`.
* **Arquitetura com Root View Controller:** Em vez de adicionar views diretamente à janela, o conteúdo é hospedado em um `S8EOverlayViewController` transparente e travado em modo retrato, garantindo o redimensionamento e atualização adequados via `viewDidLayoutSubviews`.
* **Nível de Janela e Interação Transparente:** A janela usa o nível `10.000.000` (ficando acima de tela de bloqueio, Central de Controle, notificações e banners) e implementa `_ignoresHitTest` para que todos os toques passem direto para os aplicativos.
* **Suporte Nativo a Rootless:** O projeto foi configurado com `THEOS_PACKAGE_SCHEME = rootless` (`iphoneos-arm64`), direcionando os bundles de preferências para `/var/jb` e corrigindo caminhos absolutos e chamadas de sistema.

## 📱 Compatibilidade

* **Jailbreaks rootless, iOS 15.0 ou superior** (testado no Dopamine, iOS 16.5). Builds rootful não são mais suportadas.
* ID do pacote: `com.cdustevich1.s8edge`. Ele substitui o original `com.brunonfl.s8edge`; desinstale o antigo primeiro.
* As configurações são aplicadas após um respring (há um botão Respring no painel de configurações do S8Edge).

## 💻 Como Compilar

1.  Instale o [Theos](https://theos.dev/) com um SDK do iOS (15.0 ou superior) e defina `$THEOS`.
2.  Clone o repositório:
    ```bash
    git clone https://github.com/cdustevich1/s8edge.git
    cd s8edge
    ```
3.  Compile o pacote rootless:
    ```bash
    make package
    ```
    Isso gera um `.deb` rootless `iphoneos-arm64` em `packages/`.
4.  Para instalar via SSH no seu dispositivo:
    ```bash
    make package install THEOS_DEVICE_IP=<ip-do-dispositivo>
    ```

**Créditos:** Criado originalmente por Bruno Andrade ([/u/BrunoNFL](https://reddit.com/u/BrunoNFL)) em 2017. Atualização rootless / iOS 15+ mantida por cdustevich1.
