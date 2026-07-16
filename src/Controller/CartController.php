<?php

namespace App\Controller;

use App\Repository\ProductRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Doctrine\ORM\EntityNotFoundException;

#[Route('/cart')]
class CartController extends AbstractController
{
    private RequestStack $requestStack;

    public function __construct(RequestStack $requestStack)
    {
        $this->requestStack = $requestStack;
    }

    #[Route('/', name: 'app_cart_index')]
    public function index(ProductRepository $productRepository): Response
    {
        $session = $this->requestStack->getSession();
        $cart = $session->get('cart', []);
        $cartData = [];
        $total = 0;

        foreach ($cart as $id => $quantity) {
            $product = $productRepository->find($id);
            if ($product) {
                // Ապահովում ենք, որ եթե կատեգորիան բազայից ջնջվել է, սխալ չստանանք
                try {
                    if ($product->getCategory()) {
                        $product->getCategory()->getName(); // Փորձում ենք կարդալ անունը
                    }
                } catch (\Exception $e) {
                    // Եթե կատեգորիան գոյություն չունի, կապը խզում ենք այս պահի համար
                    $product->setCategory(null);
                }

                $cartData[] = [
                    'product' => $product,
                    'quantity' => $quantity
                ];
                $total += $product->getPrice() * $quantity;
            }
        }

        return $this->render('cart/index.html.twig', [
            'items' => $cartData,
            'total' => $total
        ]);
    }

    #[Route('/add/{id}', name: 'app_cart_add')]
    public function add(int $id): Response
    {
        $session = $this->requestStack->getSession();
        
        if (!$session->isStarted()) {
            $session->start();
        }

        $cart = $session->get('cart', []);

        if (!empty($cart[$id])) {
            $cart[$id]++;
        } else {
            $cart[$id] = 1;
        }

        $session->set('cart', $cart);

        $this->addFlash('success', 'Book added to cart!');

        return $this->redirectToRoute('app_cart_index');
    }

    #[Route('/remove/{id}', name: 'app_cart_remove')]
    public function remove(int $id): Response
    {
        $session = $this->requestStack->getSession();
        $cart = $session->get('cart', []);

        if (!empty($cart[$id])) {
            unset($cart[$id]);
        }

        $session->set('cart', $cart);

        return $this->redirectToRoute('app_cart_index');
    }
}