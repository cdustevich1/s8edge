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
* **Leve e Eficiente:** Projetado para ser uma simples sobreposição de imagem, o tweak teve impacto virtualmente zero no desempenho ou na vida útil da bateria.

## 🛠️ Implementação Técnica

A eficácia do tweak veio de sua implementação simples e inteligente.

* **Sobreposição com Janela de Nível Superior:** Todo o efeito é alcançado criando uma única `UIWindow` em tela cheia que fica sobre todo o outro conteúdo (`UIWindowLevelAlert`). Esta janela é transparente e não interativa.
* **Máscara Baseada em Imagem:** O efeito "curvo" é criado adicionando uma `UIImageView` a esta janela. A imagem é uma máscara PNG simples com cantos e bordas transparentes, que se sobrepõe à UI do sistema para criar a ilusão.
* **Código Minimalista:** O tweak inteiro consiste em uma única classe, tornando-o incrivelmente leve e estável. É um testemunho de como alcançar um efeito visual popular com a solução mais simples possível.

## 💻 Como Compilar

1.  Certifique-se de que você tem a [toolchain Theos](https://theos.dev/) instalada.
2.  Clone o repositório: `git clone https://github.com/BrunoNFL/s8edge.git`
3.  Execute `make package` no diretório raiz do projeto.

**(Nota: Este projeto foi desenvolvido para versões mais antigas do iOS e pode exigir atualizações para compilar e executar em sistemas modernos.)**
